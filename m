Date: Mon, 13 Aug 2007 15:38:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070813230801.GH3406@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0708131536340.29946@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <200708102013.49170.ak@suse.de> <Pine.LNX.4.64.0708101201240.17549@schroedinger.engr.sgi.com>
 <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com>
 <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
 <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
 <20070813230801.GH3406@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just did a grep for GFP_DMA and I still see a large list of GFP_DMA 
kmallocs???


arch/mips/au1000/common/dbdma.c:		if ((desc_base = (u32)kmalloc(i, GFP_KERNEL|GFP_DMA)) == 0)
arch/m68k/kernel/dma.c:	map = kmalloc(sizeof(struct page *) << order, flag & ~__GFP_DMA);
arch/s390/hypfs/hypfs_diag.c:	diag224_cpu_names = kmalloc(PAGE_SIZE, GFP_KERNEL | GFP_DMA);
arch/s390/mm/extmem.c:	struct qin64  *qin = kmalloc (sizeof(struct qin64), GFP_DMA);
arch/s390/mm/extmem.c:	struct qout64 *qout = kmalloc (sizeof(struct qout64), GFP_DMA);
arch/s390/kernel/cpcmd.c:		lowbuf = kmalloc(rlen, GFP_KERNEL | GFP_DMA);
drivers/block/ps3disk.c:	dev->bounce_buf = kmalloc(BOUNCE_SIZE, GFP_DMA);
drivers/scsi/sr_vendor.c:	buffer = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/scsi/sr_vendor.c:	buffer = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/scsi/aha1542.c:		SCpnt->host_scribble = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/scsi/ps3rom.c:	dev->bounce_buf = kmalloc(BOUNCE_SIZE, GFP_DMA);
drivers/scsi/aacraid/commctrl.c:				p = kmalloc(upsg->sg[i].count,GFP_KERNEL|__GFP_DMA);
drivers/scsi/aacraid/commctrl.c:				p = kmalloc(usg->sg[i].count,GFP_KERNEL|__GFP_DMA);
drivers/scsi/aacraid/commctrl.c:				p = kmalloc(usg->sg[i].count,GFP_KERNEL|__GFP_DMA);
drivers/scsi/pluto.c:	fcs = kmalloc(sizeof (struct ctrl_inquiry) * fcscount, GFP_DMA);
drivers/scsi/sr_ioctl.c:	buffer = kmalloc(32, GFP_KERNEL | SR_GFP_DMA(cd));
drivers/scsi/sr_ioctl.c:	buffer = kmalloc(32, GFP_KERNEL | SR_GFP_DMA(cd));
drivers/scsi/sr_ioctl.c:	char *buffer = kmalloc(32, GFP_KERNEL | SR_GFP_DMA(cd));
drivers/scsi/sr_ioctl.c:	raw_sector = kmalloc(2048, GFP_KERNEL | SR_GFP_DMA(cd));
drivers/scsi/sr.c:	buffer = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/scsi/sr.c:	buffer = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/scsi/ch.c:	buffer = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/scsi/ch.c:		buffer = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/net/tokenring/3c359.c:	xl_priv->xl_tx_ring = kmalloc((sizeof(struct xl_tx_desc) * XL_TX_RING_SIZE) + 7, GFP_DMA | GFP_KERNEL) ; 
drivers/net/tokenring/3c359.c:	xl_priv->xl_rx_ring = kmalloc((sizeof(struct xl_rx_desc) * XL_RX_RING_SIZE) +7, GFP_DMA | GFP_KERNEL) ; 
drivers/net/znet.c:	if (!(znet->rx_start = kmalloc (DMA_BUF_SIZE, GFP_KERNEL | GFP_DMA)))
drivers/net/znet.c:	if (!(znet->tx_start = kmalloc (DMA_BUF_SIZE, GFP_KERNEL | GFP_DMA)))
drivers/net/lance.c:			rx_buff = kmalloc(PKT_BUF_SZ, GFP_DMA | gfp);
drivers/net/wan/cosa.c:	cosa->bouncebuf = kmalloc(COSA_MTU, GFP_KERNEL|GFP_DMA);
drivers/net/wan/cosa.c:	if ((chan->rxdata = kmalloc(COSA_MTU, GFP_DMA|GFP_KERNEL)) == NULL) {
drivers/net/wan/cosa.c:	if ((kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA)) == NULL) {
drivers/net/irda/sa1100_ir.c:	io->head = kmalloc(size, GFP_KERNEL | GFP_DMA);
drivers/net/irda/pxaficp_ir.c:	io->head = kmalloc(size, GFP_KERNEL | GFP_DMA);
drivers/net/irda/vlsi_ir.c:		rd->buf = kmalloc(len, GFP_KERNEL|GFP_DMA);
drivers/net/ni65.c:		ret = ptr = kmalloc(T_BUF_SIZE,GFP_KERNEL | GFP_DMA);
drivers/usb/core/buffer.c:/* sometimes alloc/free could use kmalloc with GFP_DMA, for
drivers/media/video/arv.c:	ar->line_buff = kmalloc(MAX_AR_LINE_BYTES, GFP_KERNEL | GFP_DMA);
drivers/media/dvb/dvb-usb/gp8psk.c:	buf = kmalloc(512, GFP_KERNEL | GFP_DMA);
drivers/atm/fore200e.c:	data = kmalloc(tx_len, GFP_ATOMIC | GFP_DMA);
drivers/atm/iphase.c:       	    cpcs = kmalloc(sizeof(*cpcs), GFP_KERNEL|GFP_DMA);
drivers/char/synclink.c:	info->intermediate_rxbuffer = kmalloc(info->max_frame_size, GFP_KERNEL | GFP_DMA);
drivers/s390/net/qeth_main.c:			kmalloc(QETH_BUFSIZE, GFP_DMA|GFP_KERNEL);
drivers/s390/net/smsgiucv.c:	buffer = kmalloc(msg->length + 1, GFP_ATOMIC | GFP_DMA);
drivers/s390/char/tape_core.c:	device->modeset_byte = kmalloc(1, GFP_KERNEL | GFP_DMA);
drivers/s390/char/vmur.c:		kbuf = kmalloc(reclen, GFP_KERNEL | GFP_DMA);
drivers/s390/char/vmur.c:	fcb = kmalloc(sizeof(*fcb), GFP_KERNEL | GFP_DMA);
drivers/s390/char/vmur.c:	fcb = kmalloc(sizeof(*fcb), GFP_KERNEL | GFP_DMA);
drivers/s390/char/raw3270.c:		rq->buffer = kmalloc(size, GFP_KERNEL | GFP_DMA);
drivers/s390/char/raw3270.c:	rp = kmalloc(sizeof(struct raw3270), GFP_KERNEL | GFP_DMA);
drivers/s390/char/tape_3590.c:	int_kekls = kmalloc(sizeof(*int_kekls), GFP_KERNEL|GFP_DMA);
drivers/s390/char/tape_3590.c:	rdc_data = kmalloc(sizeof(*rdc_data), GFP_KERNEL | GFP_DMA);
drivers/s390/cio/device_ops.c:	buf = kmalloc(32*sizeof(char), GFP_DMA|GFP_KERNEL);
drivers/s390/cio/device_ops.c:	buf2 = kmalloc(32*sizeof(char), GFP_DMA|GFP_KERNEL);
drivers/s390/cio/css.c:	sch = kmalloc (sizeof (*sch), GFP_KERNEL | GFP_DMA);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
