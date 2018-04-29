Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 197946B0003
	for <linux-mm@kvack.org>; Sun, 29 Apr 2018 10:34:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f21so3746351wmh.5
        for <linux-mm@kvack.org>; Sun, 29 Apr 2018 07:34:24 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id 49-v6si4925025wrc.205.2018.04.29.07.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Apr 2018 07:34:22 -0700 (PDT)
Date: Sun, 29 Apr 2018 16:34:20 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
In-Reply-To: <20180428204118.GA3305@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804291633240.3679@hadrien>
References: <20180426215406.GB27853@wotan.suse.de> <20180427053556.GB11339@infradead.org> <20180427161456.GD27853@wotan.suse.de> <20180428084221.GD31684@infradead.org> <20180428185514.GW27853@wotan.suse.de> <alpine.DEB.2.20.1804282145450.2532@hadrien>
 <20180428204118.GA3305@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Christoph Hellwig <hch@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

Here are some improved results, also taking into account the pci
functions.

julia

too small: drivers/gpu/drm/i915/i915_drv.c:1138: 30
too small: drivers/hwtracing/coresight/coresight-tmc.c:335: 0
too small: drivers/media/pci/sta2x11/sta2x11_vip.c:859: 29
too small: drivers/media/pci/sta2x11/sta2x11_vip.c:983: 26
too small: drivers/net/ethernet/broadcom/b44.c:2389: 30
too small: drivers/net/wan/wanxl.c:585: 28
too small: drivers/net/wan/wanxl.c:586: 28
too small: drivers/net/wireless/broadcom/b43/dma.c:1068: 30
too small: drivers/net/wireless/broadcom/b43legacy/dma.c:809: 30
too small: drivers/scsi/aacraid/commsup.c:1581: 31
too small: drivers/scsi/aacraid/linit.c:1651: 31
too small: drivers/usb/host/ehci-pci.c:127: 31
too small: sound/pci/ali5451/ali5451.c:2110: 31
too small: sound/pci/ali5451/ali5451.c:2111: 31
too small: sound/pci/als300.c:661: 28
too small: sound/pci/als300.c:662: 28
too small: sound/pci/als4000.c:874: 24
too small: sound/pci/als4000.c:875: 24
too small: sound/pci/azt3328.c:2421: 24
too small: sound/pci/azt3328.c:2422: 24
too small: sound/pci/emu10k1/emu10k1x.c:916: 28
too small: sound/pci/emu10k1/emu10k1x.c:917: 28
too small: sound/pci/es1938.c:1600: 24
too small: sound/pci/es1938.c:1601: 24
too small: sound/pci/es1968.c:2692: 28
too small: sound/pci/es1968.c:2693: 28
too small: sound/pci/ice1712/ice1712.c:2533: 28
too small: sound/pci/ice1712/ice1712.c:2534: 28
too small: sound/pci/maestro3.c:2557: 28
too small: sound/pci/maestro3.c:2558: 28
too small: sound/pci/sis7019.c:1328: 30
too small: sound/pci/sonicvibes.c:1262: 24
too small: sound/pci/sonicvibes.c:1263: 24
too small: sound/pci/trident/trident_main.c:3552: 30
too small: sound/pci/trident/trident_main.c:3553: 30
unknown: arch/x86/pci/sta2x11-fixup.c:169: STA2X11_AMBA_SIZE-1
unknown: arch/x86/pci/sta2x11-fixup.c:170: STA2X11_AMBA_SIZE-1
unknown: drivers/ata/sata_nv.c:762: pp->adma_dma_mask
unknown: drivers/char/agp/intel-gtt.c:1409: DMA_BIT_MASK(mask)
unknown: drivers/char/agp/intel-gtt.c:1413: DMA_BIT_MASK(mask)
unknown: drivers/crypto/ccree/cc_driver.c:260: dma_mask
unknown: drivers/dma/mmp_pdma.c:1094: pdev->dev->coherent_dma_mask
unknown: drivers/dma/pxa_dma.c:1375: op->dev.coherent_dma_mask
unknown: drivers/dma/xilinx/xilinx_dma.c:2634: DMA_BIT_MASK(addr_width)
unknown: drivers/gpu/drm/ati_pcigart.c:117: gart_info->table_mask
unknown: drivers/gpu/drm/msm/msm_drv.c:1132: ~0
unknown: drivers/gpu/drm/nouveau/nvkm/engine/device/tegra.c:313: DMA_BIT_MASK(tdev->func->iommu_bit)
unknown: drivers/gpu/host1x/dev.c:199: host->info->dma_mask
unknown: drivers/hwtracing/intel_th/core.c:379: parent->coherent_dma_mask
unknown: drivers/iommu/arm-smmu.c:1848: DMA_BIT_MASK(size)
unknown: drivers/media/pci/intel/ipu3/ipu3-cio2.c:1759: CIO2_DMA_MASK
unknown: drivers/media/platform/qcom/venus/core.c:186: core->res->dma_mask
unknown: drivers/message/fusion/mptbase.c:4599: ioc->dma_mask
unknown: drivers/message/fusion/mptbase.c:4600: ioc->dma_mask
unknown: drivers/net/ethernet/altera/altera_tse_main.c:1449: DMA_BIT_MASK(priv->dmaops->dmamask)
unknown: drivers/net/ethernet/altera/altera_tse_main.c:1450: DMA_BIT_MASK(priv->dmaops->dmamask)
unknown: drivers/net/ethernet/amazon/ena/ena_netdev.c:2455: DMA_BIT_MASK(dma_width)
unknown: drivers/net/ethernet/amazon/ena/ena_netdev.c:2461: DMA_BIT_MASK(dma_width)
unknown: drivers/net/ethernet/amd/pcnet32.c:1558: PCNET32_DMA_MASK
unknown: drivers/net/ethernet/amd/xgbe/xgbe-main.c:294: DMA_BIT_MASK(pdata->hw_feat.dma_width)
unknown: drivers/net/ethernet/broadcom/bnx2.c:8234: persist_dma_mask
unknown: drivers/net/ethernet/broadcom/tg3.c:17781: persist_dma_mask
unknown: drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c:315: old_mask
unknown: drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c:316: old_cmask
unknown: drivers/net/ethernet/sfc/efx.c:1298: dma_mask
unknown: drivers/net/ethernet/sfc/falcon/efx.c:1251: dma_mask
unknown: drivers/net/ethernet/synopsys/dwc-xlgmac-common.c:96: DMA_BIT_MASK(pdata->hw_feat.dma_width)
unknown: drivers/net/wireless/ath/wil6210/pcie_bus.c:299: DMA_BIT_MASK(dma_addr_size[i])
unknown: drivers/net/wireless/ath/wil6210/pmc.c:132: DMA_BIT_MASK(wil->dma_addr_size)
unknown: drivers/net/wireless/ath/wil6210/txrx.c:200: DMA_BIT_MASK(wil->dma_addr_size)
unknown: drivers/scsi/3w-xxxx.c:2260: TW_DMA_MASK
unknown: drivers/scsi/hptiop.c:1312: DMA_BIT_MASK(iop_ops->hw_dma_bit_mask)
unknown: drivers/scsi/megaraid/megaraid_sas_base.c:6036: consistent_mask
unknown: drivers/scsi/sym53c8xx_2/sym_glue.c:1315: DMA_DAC_MASK
unknown: drivers/usb/gadget/udc/bdc/bdc_pci.c:86: pci->dev.coherent_dma_mask
unknown: sound/pci/emu10k1/emu10k1_main.c:1910: emu->dma_mask

----------------

@initialize:ocaml@
@@

let clean s = String.concat "" (Str.split (Str.regexp " ") s)

let shorten s = List.nth (Str.split (Str.regexp "linux-next/") s) 1

let ios s =
  match Str.split_delim (Str.regexp "ULL") s with
    [n;""] -> int_of_string n
  | _ -> int_of_string s

let number x = try ignore(ios x); true with _ -> false

let smallnumber x = (ios x) < 32

let longnumber x =
  number x && String.length x >= 10 && not(String.get x 2 = '0')

@ok1 exists@
position p1,p2;
constant c1 : script:ocaml() { number c1 };
constant c2 : script:ocaml() { number c2 };
expression x, e, e1, e2;
@@

x =@p1 \(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\)
... when any
    when != x = e2
\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)(e,DMA_BIT_MASK(x))

@bad1 exists@
position ok1.p2;
position p1 != ok1.p1;
expression ok1.x, e, e2;
@@

x =@p1 e
... when any
    when != x = e2
\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)(e,DMA_BIT_MASK(x))

@script:ocaml depends on bad1@
_p2 << ok1.p2;
@@

Coccilib.include_match false

@ok1a exists@
position ok1.p1,ok1.p2;
constant c1 : script:ocaml() { number c1 };
constant c2 : script:ocaml() { number c2 };
expression x, e, e1, e2;
@@

x =@p1 \(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\)
... when any
    when != x = e2
\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)(e,DMA_BIT_MASK(x))

@script:ocaml@
c1 << ok1a.c1;
c2 << ok1a.c2 = "64";
p2 << ok1.p2;
@@

let p2 = List.hd p2 in
(if smallnumber c1
then Printf.printf "too small: %s:%d: %s\n" (shorten p2.file) p2.line c1);
(if smallnumber c2
then Printf.printf "too small: %s:%d: %s\n" (shorten p2.file) p2.line c2)

(* ------------------------------------------------------------------ *)

@ok2 exists@
position p1,p2;
constant c1 : script:ocaml() { number c1 };
constant c2 : script:ocaml() { number c2 };
constant c3 : script:ocaml() { longnumber c3 };
expression x, e, e1, e2, e3;
@@

x =@p1 \(DMA_BIT_MASK(\(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\))\|
           DMA_BIT_MASK(\(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\))&e3\|
	   c3\|ATA_DMA_MASK\)
... when any
    when != x = e2
\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)(e,x)

@bad2 exists@
position ok2.p2;
position p1 != ok2.p1;
expression ok2.x, e, e2;
@@

x =@p1 e
... when any
    when != x = e2
\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)(e,x)

@script:ocaml depends on bad2@
_p2 << ok2.p2;
@@

Coccilib.include_match false

@ok2a exists@
position ok2.p1,ok2.p2;
constant c1 : script:ocaml() { number c1 };
constant c2 : script:ocaml() { number c2 };
constant c3 : script:ocaml() { longnumber c3 };
expression x, e, e1, e2, e3;
@@

x =@p1 \(DMA_BIT_MASK(\(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\))\|
           DMA_BIT_MASK(\(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\))&e3\|
	   c3\|ATA_DMA_MASK\)
... when any
    when != x = e2
\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)(e,x)

@script:ocaml@
c1 << ok2a.c1;
c2 << ok2a.c2 = "64";
p2 << ok2.p2;
@@

let p2 = List.hd p2 in
(if smallnumber c1
then Printf.printf "too small: %s:%d: %s\n" (shorten p2.file) p2.line c1);
(if smallnumber c2
then Printf.printf "too small: %s:%d: %s\n" (shorten p2.file) p2.line c2)

(* ------------------------------------------------------------------ *)

@ok3@
position p2;
constant c1 : script:ocaml() { number c1 };
constant c2 : script:ocaml() { number c2 };
constant c3 : script:ocaml() { longnumber c3 };
expression e, e1, e3;
@@

\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)
      (e,\(DMA_BIT_MASK(\(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\))\|
           DMA_BIT_MASK(\(BITS_PER_LONG\|NFP_NET_MAX_DMA_BITS\|e1 ? c1 : c2\|c1\|c1+e1\))&e3\|
	   c3\|ATA_DMA_MASK\))

@script:ocaml@
c1 << ok3.c1;
c2 << ok3.c2 = "64";
p2 << ok3.p2;
@@

let p2 = List.hd p2 in
(if smallnumber c1
then Printf.printf "too small: %s:%d: %s\n" (shorten p2.file) p2.line c1);
(if smallnumber c2
then Printf.printf "too small: %s:%d: %s\n" (shorten p2.file) p2.line c2)

@unk@
position p2 != {ok1.p2,ok2.p2,ok3.p2};
expression e, e1;
@@

\(dma_set_mask@p2\|dma_set_coherent_mask@p2\|dma_set_mask_and_coherent@p2\|
  pci_set_dma_mask@p2\|pci_set_consistent_dma_mask@p2\)
      (e,e1)

@script:ocaml@
p2 << unk.p2;
e1 << unk.e1;
@@

let p2 = List.hd p2 in
Printf.printf "unknown: %s:%d: %s\n" (shorten p2.file) p2.line (clean e1)
