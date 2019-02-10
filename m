Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE809C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 12:00:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F79121841
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 12:00:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="nwwPd9dj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F79121841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D98688E00BB; Sun, 10 Feb 2019 07:00:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D48868E00B5; Sun, 10 Feb 2019 07:00:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C36928E00BB; Sun, 10 Feb 2019 07:00:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E87E8E00B5
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 07:00:33 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o16so4710979wmh.6
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 04:00:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=n33DcogtNyDZz6kzk6IjadlOjeDlmA/nSiofmi/mng4=;
        b=DM3Z3FJys4H5qdr7GmlXOGx5teQcmnu67gq1Yim+yH46YOJi7j5bVGfJn83ro7p/j9
         3BPYKNKoQGiGbA7e5chAKLg0ZyNChuEapWI6YqvM/9+ZkJMRtIpEtolNYajIRGG7BrfD
         ALYwmk0QaebTvNkRzoZEFnkcW4Gz8hjQ29AtUDikaXY2XXsDGCb4nWw/RxtA18wV8gGQ
         qiZM3DLBqA/P7WJM8vDCu+3SD+jNgUlHSVJ1gqUSuBxpS2couVTucwBsEj5EeNXYX6H1
         xTxJDDFFm5K/5mc60MIXGEs78wyI4Fdi0QyVAGcOd9xoG/nsSoo6O3vQolC+/iA1ld0d
         JKKw==
X-Gm-Message-State: AHQUAuar6Pkq0Uc4bzQjppobSRgDeQPIiMP6PMycyx86uXC1pHFBNBCF
	ByVXvLQB5EhHP6WnYw93Qr8svgA9d5OweVd0drtiglBDS0H3lhuYcRBGfofDR5EFWIxM5IutOKE
	LwKET3COOuMM9H4VIYZlsoS5dkgNE1Bn4S7jkMnixt1hqOI1bD/UHNyVGmalX8h+aeA==
X-Received: by 2002:a1c:7dd7:: with SMTP id y206mr636712wmc.123.1549800032807;
        Sun, 10 Feb 2019 04:00:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+yoTCgTXI53dykf9z/qHxuGeweJmvIuINNv6aIjGOYXhGrVgDrVNuZ9if7yAPevDIzEpS
X-Received: by 2002:a1c:7dd7:: with SMTP id y206mr636661wmc.123.1549800031439;
        Sun, 10 Feb 2019 04:00:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549800031; cv=none;
        d=google.com; s=arc-20160816;
        b=q8/+5jv35qs7TBd8v5T+duHy4O9K7FLEwzrE5VUkWgtfq6AZ+pOTF7fmLFNSSsuFWB
         Fmi5afkWMyKZOptBP+Nuo2+9IafwojCsk3rZ8u22w1nK0rnagDyaXVeHX8MOMmM/JytO
         faWt/0sotAz5dUyPB5Fc1FVzb2xHPBI+31uaI4HESR172Ntmp9twDTm4SFiChGfs91pt
         +kZNBHvYDeVwhcak+87sWhbtWmSAWYiV0Z+y3Oltwz4e0qx8OmZ1Ifdgy3yM/oPedS58
         EwT2fnC9sqF0pOEm9+WCILB/+cMPnqIaKHJBW6bgTpFCDzjDs5drCK6CTMc6ugG9Gqps
         YDGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=n33DcogtNyDZz6kzk6IjadlOjeDlmA/nSiofmi/mng4=;
        b=HlXrL12RSaBFt+5N74zAwklpZQFQm4ybrmJZYPqJWp9v2c4dSlRtH7rd9Ddusu0WME
         Yi/Ccts1O+Uo1cCRMfAYBr/urFKHUvtJkoU7r++DnPE1hP9uv9il0pa26JMSLO7a2+fz
         3FDkbh2JR2qbBxeXeHD6rcvF1bfsc2SnaLpaz82RKRpMsbWj63CDdjEJeDpppyezmdUo
         8Gr89/WZFcnxM4OOczLuGpWVydaXUUWv7G4JrHVxl96dOMVloEM6sj6pfNdKaK0w5xLc
         geiCASSdrBmtqNCAKI2sRALOmrv9K99CqPFya+aG0zn/taT+Jp6sYstMuS7g1Vws+Vl3
         VTHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=nwwPd9dj;
       spf=neutral (google.com: 2a01:238:20a:202:5301::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::9])
        by mx.google.com with ESMTPS id 60si7171514wrm.369.2019.02.10.04.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 04:00:31 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5301::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5301::9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=nwwPd9dj;
       spf=neutral (google.com: 2a01:238:20a:202:5301::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1549800030;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:From:References:Cc:To:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=n33DcogtNyDZz6kzk6IjadlOjeDlmA/nSiofmi/mng4=;
	b=nwwPd9djCh0JHac4ITTNeLU2Rf7fZWIx17bsB1SFptHaYpSWN0oS/mncg9gNRqYr2g
	j5bNIc7zUBaOvsPgZADvpxBndKI3hJ4LEQXP4nnUxG38KGFfIlyiedaugTuiFk6QbwoZ
	s6ZRBYOV0ULw8z4R+QKUs6pJBWfxBzjMS6UGCm9NAojb74HNaRmiTFsA+K4oTRVJ3BUg
	3oECpx1imZaXscpm8fNRsRF6SFQyebBW531TnjYON1hk4adN526jdzqOWWtw8/7qIi0X
	kvO+bx7iSSXTa1V1QouoHWzoVAzJkZrq8HDPNi+7z9r03gIWkBOm3jIAy2lbxu+lEF6/
	t4iw==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7CleiqvAq6ZQABFXwQhWphfFlPh+VA=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:a4a8:a1be:d22f:cc48]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv1AC0KDeL
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Sun, 10 Feb 2019 13:00:20 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <9632DCDF-B9D9-416C-95FC-006B6005E2EC@xenosoft.de>
 <594beaae-9681-03de-9f42-191cc7d2f8e3@xenosoft.de>
 <20190204075616.GA5408@lst.de>
 <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de>
 <20190204123852.GA10428@lst.de>
 <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de>
 <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de>
 <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de>
 <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de>
 <20190208091818.GA23491@lst.de>
From: Christian Zigotzky <chzigotzky@xenosoft.de>
Message-ID: <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
Date: Sun, 10 Feb 2019 13:00:20 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190208091818.GA23491@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On 08 February 2019 at 10:18AM, Christoph Hellwig wrote:
> On Fri, Feb 08, 2019 at 10:01:46AM +0100, Christian Zigotzky wrote:
>> Hi Christoph,
>>
>> Your new patch fixes the problems with the P.A. Semi Ethernet! :-)
> Thanks a lot once again for testing!
>
> Now can you test with this patch and the whole series?
>
> I've updated the powerpc-dma.6 branch to include this fix.
>
I tested the whole series today. The kernels boot and the P.A. Semi 
Ethernet works! :-) Thanks a lot!

I also tested it in a virtual e5500 QEMU machine today. Unfortunately 
the kernel crashes.

Log:

[   54.624330] BUG: Unable to handle kernel data access at 
0xc06c008a0013014a
[   54.625640] Faulting instruction address: 0xc000000000027e7c
[   54.626140] Oops: Kernel access of bad area, sig: 11 [#1]
[   54.626456] BE SMP NR_CPUS=4 QEMU e500
[   54.626876] Modules linked in:
[   54.627284] CPU: 1 PID: 1876 Comm: systemd-journal Not tainted 
5.0.0-rc5-DMA_A1-X5000-54581-gda1d065-dirty #1
[   54.627819] NIP:  c000000000027e7c LR: c0000000000b5264 CTR: 
0000000000000000
[   54.628173] REGS: c00000007ffeb700 TRAP: 0300   Not tainted 
(5.0.0-rc5-DMA_A1-X5000-54581-gda1d065-dirty)
[   54.628607] MSR:  0000000080009000 <EE,ME>  CR: 44008486 XER: 00000000
[   54.629023] DEAR: c06c008a0013014a ESR: 0000000000800000 IRQMASK: 0
[   54.629023] GPR00: 0000000000005254 c00000007ffeb990 c0000000016b2000 
c06c008a0013014a
[   54.629023] GPR04: c00000007c54f8c0 0000000000000058 0000000000000006 
0000000000000000
[   54.629023] GPR08: 0000000000000000 000000007c54f8c0 006c008a0013014a 
c00000007c86c000
[   54.629023] GPR12: 0000000028002482 c00000003ffff8c0 0000000000000000 
c000000078dfaa70
[   54.629023] GPR16: c000000078366c00 0000000000000000 000000000000005e 
0000000000000000
[   54.629023] GPR20: 0000000000000000 c00000007c54f8c0 0000000000000007 
c000000078dfa000
[   54.629023] GPR24: 0000000000000000 0000000000000047 0000000000000000 
80000000003f6470
[   54.629023] GPR28: c00000007928d470 c000000078801dc0 000000000000005e 
c000000078dfa7c0
[   54.632572] NIP [c000000000027e7c] .memcpy+0x1fc/0x288
[   54.632886] LR [c0000000000b5264] .swiotlb_tbl_sync_single+0xb0/0xe4
[   54.633221] Call Trace:
[   54.633513] [c00000007ffeb990] [c00000007ffeba70] 0xc00000007ffeba70 
(unreliable)
[   54.633988] [c00000007ffeba00] [c0000000000b41e4] 
.dma_direct_sync_single_for_cpu+0x58/0x6c
[   54.634436] [c00000007ffeba70] [c000000000788da4] 
.e1000_clean_rx_irq+0x1bc/0x4c8
[   54.634857] [c00000007ffebb90] [c00000000078667c] 
.e1000_clean+0x714/0x8d4
[   54.635263] [c00000007ffebcc0] [c000000000a3f15c] 
.net_rx_action+0x11c/0x2a4
[   54.635712] [c00000007ffebdb0] [c000000000c48c20] 
.__do_softirq+0x150/0x2a8
[   54.636211] [c00000007ffebeb0] [c000000000064184] .irq_exit+0x6c/0xc4
[   54.636533] [c00000007ffebf20] [c000000000004124] .__do_irq+0x80/0x94
[   54.636985] [c00000007ffebf90] [c00000000000eca0] .call_do_irq+0x14/0x24
[   54.637371] [c00000007c86fd80] [c0000000000041c0] .do_IRQ+0x88/0xc4
[   54.637737] [c00000007c86fe20] [c000000000012920] 
exc_0x500_common+0xd8/0xdc
[   54.638104] Instruction dump:
[   54.638451] e861fff8 4e800020 7cd01120 7ca62850 38e00000 28a50010 
409f0010 88040000
[   54.638887] 98030000 38e70001 409e0010 7c07222e <7c071b2e> 38e70002 
409d000c 7c07202e
[   54.639594] ---[ end trace a4861de7e4c199f7 ]---
[   54.639873]
[   55.640484] Kernel panic - not syncing: Aiee, killing interrupt handler!
[   55.641556] Rebooting in 180 seconds..

-----

I tested with the following QEMU commands:

./qemu-system-ppc64 -M ppce500 -cpu e5500 -m 2048  -nographic -kernel 
/home/christian/Downloads/vmlinux-5.0-rc5-2-AmigaOne_X1000_X5000/X5000_and_QEMU_e5500/uImage-5.0 
-nic user,model=e1000 -drive 
format=raw,file=/home/christian/Downloads/MATE_PowerPC_Remix_2017_0.9.img,index=0,if=virtio 
-append "rw root=/dev/vda" -smp 4

./qemu-system-ppc64 -M ppce500 -cpu e5500 -m 2048 -kernel 
/home/christian/Downloads/vmlinux-5.0-rc5-2-AmigaOne_X1000_X5000/X5000_and_QEMU_e5500/uImage-5.0 
-drive 
format=raw,file=/home/christian/Downloads/MATE_PowerPC_Remix_2017_0.9.img,index=0,if=virtio 
-nic user,model=e1000 -append "rw root=/dev/vda" -device virtio-vga 
-device virtio-mouse-pci -device virtio-keyboard-pci -usb -soundhw 
es1370 -smp 4

The RC5 of kernel 5.0 boots without any problems in this virtual machine.

Cheers,
Christian

