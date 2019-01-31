Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70A0BC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:48:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 077712086C
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:48:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=xenosoft.de header.i=@xenosoft.de header.b="JiYMOaMb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 077712086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=xenosoft.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 854708E0002; Thu, 31 Jan 2019 07:48:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 805408E0001; Thu, 31 Jan 2019 07:48:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A5A88E0002; Thu, 31 Jan 2019 07:48:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE7A8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:48:39 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id z16so1015456wrt.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:48:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=EqQYlxpU6mBYE+dw1eVkplvtBBO9xJm9m5wbjwiYkAw=;
        b=fzZFb3P+a24e04HCzduBSqKCbCOt65fBJwUVOaOpQBYk/onz9NdTuloZl7lAyeZSFr
         Sdkc3yhQaPM6WQWw6cqzKr4PYNK+45r6lqI2d580+s012GM3Lg3o6uwTdE+QGNO4i4CH
         IZur96sM9Bv//ww4iiC1E/nzCLenB+ChGPggz5H962XcZLdzpn4CBs7TYVrVRtWfgOC6
         x0OKqpDL+FfOYPSfh9jrO5L/HTnNWi6BF93PgAu4fXUFqa1BIEeWJprpXc3+Vd7ZApQ4
         7iA7OaFocPxBqpyUZDsK/C24XXuigO4zzCVDWQ/doGyzPE/sT/dMJaEmlCPzt0GAl9zE
         qgmA==
X-Gm-Message-State: AHQUAublJJVJcDCwnTHLcoepITCR2/MhnMPV7ILWpmP+BBLy7Ow0lP46
	LoSgciN8XxK1ewT3gTLyZLezbEwFGmlYBuAxRhqcGexq+9zN/s9oXIwaKd8xa20tFFSMUZfh3Pd
	jYJteneis4PwdLjZz4Pa8mA71V/XhCx41r2dQily1wzk2RZv8iL1dTb7pU5qfTbnKKA==
X-Received: by 2002:adf:c38e:: with SMTP id p14mr6512204wrf.68.1548938918418;
        Thu, 31 Jan 2019 04:48:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY6xAnOA0KaebAh+3Pnpr81PEteTg6/hTsLb3APKmZCJQvHxMfdvweLPbslf/Bim8uC02O8
X-Received: by 2002:adf:c38e:: with SMTP id p14mr6512137wrf.68.1548938917297;
        Thu, 31 Jan 2019 04:48:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548938917; cv=none;
        d=google.com; s=arc-20160816;
        b=smRjypWbnqyVukTQWjZH2zn5xoPDFWTwQdioabGlliPOHlZqHzKyBb4xqDI9tdCXOf
         +uqprOpIrzWqlXNzx0kU+BnWHKTek+DFYB+pA2XKBd70gszVG7CJHyPrMxG/O1Z54s0L
         OwKRe1ix2QVfXbP/eAibdSbnBIXRKjC70Phgn+DS9BJepQXCYeHZZ1qX37Z1VmRnr3ct
         5roErzUHjzvNGuNUK8CnY6ayVFzrXelL7u1QfhhEVFpSpwAtHFWmnEaXYiSmmjgz+Rx6
         MqlO3qGnMapMXbsUS3kpmfvgQcyYhoFqTkCeljCDxZQb9taIBDgwVV+MamTynh6gEEHY
         V7zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=EqQYlxpU6mBYE+dw1eVkplvtBBO9xJm9m5wbjwiYkAw=;
        b=g4JFhEsio0oUvYcdi1luCeWxaGqMgad0rGSJkYxUNdyRySGcokgCK7sWub/W8HuKCT
         6npvQWcI2CXDWgahsIGQ0DUWYThiPwOgmrj4QiY2axDlzbFzrUWPtrxz/eI31Q83ch6a
         0bXnOkNwb4q97yPRH7f016/DnJd4VaLReLNkLIFEcRZV7ecZXK7VnrQ5b1dNvekk8WwB
         /0pYf2bJ9uujOJFKi+ol+LXsp3L9kGln7bwZ5d7/l7Hn6is03rD7JAid4otXVTHlt6Ni
         5nnrflf54+sU6JSASzg9OGgoQqFdp9GAuS3hJoS/YDgR9Er9FWJnmSK8BujeabNNyoQd
         fKiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=JiYMOaMb;
       spf=neutral (google.com: 2a01:238:20a:202:5302::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
Received: from mo6-p02-ob.smtp.rzone.de (mo6-p02-ob.smtp.rzone.de. [2a01:238:20a:202:5302::9])
        by mx.google.com with ESMTPS id g11si3258215wru.308.2019.01.31.04.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 04:48:37 -0800 (PST)
Received-SPF: neutral (google.com: 2a01:238:20a:202:5302::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) client-ip=2a01:238:20a:202:5302::9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@xenosoft.de header.s=strato-dkim-0002 header.b=JiYMOaMb;
       spf=neutral (google.com: 2a01:238:20a:202:5302::9 is neither permitted nor denied by best guess record for domain of chzigotzky@xenosoft.de) smtp.mailfrom=chzigotzky@xenosoft.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; t=1548938916;
	s=strato-dkim-0002; d=xenosoft.de;
	h=In-Reply-To:Date:Message-ID:References:Cc:To:From:Subject:
	X-RZG-CLASS-ID:X-RZG-AUTH:From:Subject:Sender;
	bh=EqQYlxpU6mBYE+dw1eVkplvtBBO9xJm9m5wbjwiYkAw=;
	b=JiYMOaMboKs3jLv/XD7ORjUhMv1bBKtCFFx9fdTyk521WO8vDILnlVG7vrGavqZyXw
	fLZ26lgh5RVkmK+/G5qZrRbdczJG9sUJUhOL7CGcXBgsPOHpX/Egxt5m1ht989ku7Ksi
	UV7uC7VnHr2aClq4A3Vx+e7PjpB5Dvz9lc+oDOl2fcI3MUESXU1+GOUonI0/HpkBbduq
	jGdmQEWgLB46drE1vfY08qhbDUFQqYDkGLqX0eInAZWOiqTKJN93DfFp+VhchIBPxM96
	qyjbqtRbZPirJZvltmCOsCRuUx6+XGV8fKWCJ4+682U93VGg5PJSAvBMuEiOsyuVEECp
	1kMA==
X-RZG-AUTH: ":L2QefEenb+UdBJSdRCXu93KJ1bmSGnhMdmOod1DhGM4l4Hio94KKxRySfLxnHfJ+Dkjp5G5MdirQj0WG7Clbj7FgaTSY4jzuFv3SP8KtXZNiDQ=="
X-RZG-CLASS-ID: mo00
Received: from [IPv6:2a02:8109:a400:162c:d119:512c:5b90:22aa]
	by smtp.strato.de (RZmta 44.9 AUTH)
	with ESMTPSA id t0203dv0VCmRObC
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate);
	Thu, 31 Jan 2019 13:48:27 +0100 (CET)
Subject: Re: use generic DMA mapping code in powerpc V4
From: Christian Zigotzky <chzigotzky@xenosoft.de>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-arch@vger.kernel.org, Darren Stevens <darren@stevens-zone.net>,
 linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
 linuxppc-dev@lists.ozlabs.org
References: <20190119140452.GA25198@lst.de>
 <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de>
 <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de>
 <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de>
 <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de>
 <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de>
 <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de>
 <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
 <20190129161411.GA14022@lst.de> <20190129163415.GA14529@lst.de>
 <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
Message-ID: <96762cd2-65fc-bce5-8c5b-c03bc3baf0a1@xenosoft.de>
Date: Thu, 31 Jan 2019 13:48:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <F4AB3D9A-97EC-45D7-9061-A750D0934C3C@xenosoft.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

I compiled kernels for the X5000 and X1000 from your branch 
'powerpc-dma.6' today.

Gitweb: 
http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6

git clone git://git.infradead.org/users/hch/misc.git -b powerpc-dma.6 a

The X1000 and X5000 boot but unfortunately the P.A. Semi Ethernet 
doesn't work.

Error messages (X1000):

[   17.371736] pci 0000:00:1a.0: overflow 0x00000002691bf802+1646 of DMA 
mask ffffffff bus mask 0
[   17.371760] WARNING: CPU: 0 PID: 2496 at kernel/dma/direct.c:43 
.dma_direct_map_page+0x11c/0x200
[   17.371762] Modules linked in:
[   17.371769] CPU: 0 PID: 2496 Comm: NetworkManager Not tainted 
5.0.0-rc4-3_A-EON_AmigaOne_X1000_Nemo-54580-g8d7a724-dirty #2
[   17.371772] NIP:  c00000000010395c LR: c000000000103a30 CTR: 
c000000000726f70
[   17.371775] REGS: c00000026900e9a0 TRAP: 0700   Not tainted 
(5.0.0-rc4-3_A-EON_AmigaOne_X1000_Nemo-54580-g8d7a724-dirty)
[   17.371777] MSR:  9000000000029032 <SF,HV,EE,ME,IR,DR,RI> CR: 
24002222  XER: 20000000
[   17.371786] IRQMASK: 0
                GPR00: c000000000103a30 c00000026900ec30 
c000000001923f00 0000000000000052
                GPR04: c00000026f206778 c00000026f20d458 
0000000000000000 0000000000000346
                GPR08: 0000000000000007 0000000000000000 
0000000000000000 0000000000000010
                GPR12: 0000000022002444 c000000001b10000 
0000000000000000 0000000000000000
                GPR16: 0000000010382410 0000000000000000 
0000000000000000 c00000026bd9d820
                GPR20: 0000000000000000 c00000026919c000 
0000000000000000 0000000000000000
                GPR24: 0000000000000800 c000000269190000 
c0000002692a4180 c000000269190000
                GPR28: c000000277ada1c8 000000000000066e 
c00000026d3c68b0 0000000000000802
[   17.371823] NIP [c00000000010395c] .dma_direct_map_page+0x11c/0x200
[   17.371827] LR [c000000000103a30] .dma_direct_map_page+0x1f0/0x200
[   17.371829] Call Trace:
[   17.371833] [c00000026900ec30] [c000000000103a30] 
.dma_direct_map_page+0x1f0/0x200 (unreliable)
[   17.371840] [c00000026900ecd0] [c00000000099b7ec] 
.pasemi_mac_replenish_rx_ring+0x12c/0x2a0
[   17.371846] [c00000026900eda0] [c00000000099dc64] 
.pasemi_mac_open+0x384/0x7c0
[   17.371853] [c00000026900ee40] [c000000000c6f484] .__dev_open+0x134/0x1e0
[   17.371858] [c00000026900eee0] [c000000000c6f9ec] 
.__dev_change_flags+0x1bc/0x210
[   17.371863] [c00000026900ef90] [c000000000c6fa88] 
.dev_change_flags+0x48/0xa0
[   17.371869] [c00000026900f030] [c000000000c8c88c] .do_setlink+0x3dc/0xf60
[   17.371875] [c00000026900f1b0] [c000000000c8dd84] 
.__rtnl_newlink+0x5e4/0x900
[   17.371880] [c00000026900f5f0] [c000000000c8e10c] .rtnl_newlink+0x6c/0xb0
[   17.371885] [c00000026900f680] [c000000000c89838] 
.rtnetlink_rcv_msg+0x2e8/0x3d0
[   17.371891] [c00000026900f760] [c000000000cc0f90] 
.netlink_rcv_skb+0x120/0x170
[   17.371896] [c00000026900f820] [c000000000c87318] 
.rtnetlink_rcv+0x28/0x40
[   17.371901] [c00000026900f8a0] [c000000000cc03f8] 
.netlink_unicast+0x208/0x2f0
[   17.371906] [c00000026900f950] [c000000000cc09a8] 
.netlink_sendmsg+0x348/0x460
[   17.371911] [c00000026900fa30] [c000000000c38774] .sock_sendmsg+0x44/0x70
[   17.371915] [c00000026900fab0] [c000000000c3a79c] 
.___sys_sendmsg+0x30c/0x320
[   17.371920] [c00000026900fca0] [c000000000c3c3b4] 
.__sys_sendmsg+0x74/0xf0
[   17.371926] [c00000026900fd90] [c000000000cb4da0] 
.__se_compat_sys_sendmsg+0x40/0x60
[   17.371932] [c00000026900fe20] [c00000000000a21c] system_call+0x5c/0x70
[   17.371934] Instruction dump:
[   17.371937] 60000000 f8610070 3d20ffff 6129fffe 79290020 e8e70000 
7fa74840 409d00b8
[   17.371946] 3d420001 892acb59 2f890000 419e00b8 <0fe00000> 382100a0 
3860ffff e8010010
[   17.371954] ---[ end trace a81f3c344f625f76 ]---
[   17.396654] IPv6: ADDRCONF(NETDEV_UP): enp0s20f3: link is not ready

--------

Additionally, Xorg doesn't start on a virtual e5500 QEMU machine 
anymore. I tested with the following QEMU command:

./qemu-system-ppc64 -M ppce500 -cpu e5500 -m 2048 -kernel 
/home/christian/Downloads/vmlinux-5.0-rc4-3-AmigaOne_X1000_X5000/X5000_and_QEMU_e5500/uImage-5.0 
-drive 
format=raw,file=/home/christian/Downloads/Fienix-Beta120418.img,index=0,if=virtio 
-nic user,model=e1000 -append "rw root=/dev/vda" -device virtio-vga 
-device virtio-mouse-pci -device virtio-keyboard-pci -usb -soundhw 
es1370 -smp 4

Cheers,
Christian


On 30 January 2019 at 05:40AM, Christian Zigotzky wrote:
> Hi Christoph,
>
> Thanks a lot for the updates. I will test the full branch tomorrow.
>
> Cheers,
> Christian
>
> Sent from my iPhone
>
>> On 29. Jan 2019, at 17:34, Christoph Hellwig <hch@lst.de> wrote:
>>
>>> On Tue, Jan 29, 2019 at 05:14:11PM +0100, Christoph Hellwig wrote:
>>>> On Tue, Jan 29, 2019 at 04:03:32PM +0100, Christian Zigotzky wrote:
>>>> Hi Christoph,
>>>>
>>>> I compiled kernels for the X5000 and X1000 from your new branch
>>>> 'powerpc-dma.6-debug.2' today. The kernels boot and the P.A. Semi Ethernet
>>>> works!
>>> Thanks for testing!  I'll prepare a new series that adds the other
>>> patches on top of this one.
>> And that was easier than I thought - we just had a few patches left
>> in powerpc-dma.6, so I've rebased that branch on top of
>> powerpc-dma.6-debug.2:
>>
>>     git://git.infradead.org/users/hch/misc.git powerpc-dma.6
>>
>> Gitweb:
>>
>>     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6
>>
>> I hope the other patches are simple enough, so just testing the full
>> branch checkout should be fine for now.


