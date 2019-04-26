//-----------------------------------------------------------------------------
//		�O�H�d�@�}�C�R���@��\�t�g�E�F�A�������
//
//	File		:	mu500-rx.h
//	Contents	:	MU500-RX�p��`�w�b�_�t�@�C��
//	Date		:	2012-3-21
//-----------------------------------------------------------------------------
#ifndef __MU500_RX_H__
#define __MU500_RX_H__

#ifdef __cplusplus
extern "C" {
#endif


//-----------------------------------------------------------------------------
// �s���z���`
//-----------------------------------------------------------------------------
// ���W�X�^��`					reg
//		FPGA�֘A
#define	CYCLONE_A_OUT			PORTB.PIDR.BIT.B0	// No Use
#define	CYCLONE_A1				PORTE.PODR.BIT.B1	// Output
#define	CYCLONE_A2				PORTE.PODR.BIT.B2	// Output
#define	CYCLONE_A3				PORTE.PODR.BIT.B3	// Output
#define	CYCLONE_A4				PORTE.PODR.BIT.B4	// Output
#define	CYCLONE_A5				PORTE.PODR.BIT.B5	// Output
#define	CYCLONE_A6				PORTE.PODR.BIT.B6	// Output
#define	CYCLONE_A7				PORTE.PODR.BIT.B7	// Output
#define	CYCLONE_B0				PORT5.PIDR.BIT.B0	// Input
#define	CYCLONE_B1				PORT5.PIDR.BIT.B1	// Input
#define	CYCLONE_B2				PORT5.PIDR.BIT.B2	// Input
#define	CYCLONE_B3				PORT5.PIDR.BIT.B3	// Input


#define POTR5_MODE				PORT5.PDR.BYTE		//PORT5 �ݒ背�W�X�^
#define POTRE_MODE				PORTE.PDR.BYTE		//PORTE �ݒ背�W�X�^


#ifdef __cplusplus
}
#endif

#endif /* __MU500_RX_H__ */
/*----------------------          End of File          ----------------------*/
