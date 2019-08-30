Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE1D2C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 719FD21897
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 13:35:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="X4PXDlxJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 719FD21897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3CD46B0006; Fri, 30 Aug 2019 09:35:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EECC36B0008; Fri, 30 Aug 2019 09:35:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E020B6B000A; Fri, 30 Aug 2019 09:35:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id BA7236B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 09:35:56 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 666DD181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:35:56 +0000 (UTC)
X-FDA: 75879192312.10.beam16_168e80e537d0c
X-HE-Tag: beam16_168e80e537d0c
X-Filterd-Recvd-Size: 5396
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk [78.32.30.218])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:35:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=cX5HAPQ/pGMAWfMOWWax1diaBYat5jfFHPLeFudRYV0=; b=X4PXDlxJk6XPR03/tA1Mmat89
	OfVyp7FrasZ+Qk7+5Z8u6qXX2PI2/X1pZpstwrBjdGaTixrEdRhSvmtsd+zwZ0BYoXFpLbCUXQQNv
	aW3KWuf6Ep+uGE61r17wYLEA2GrUAlPt8vznDSF7SVgWYOjmU5KZyXoW//REk0/AeCtY6pg2JnZ0U
	Xfs38hH9Gx3tH9Hs6YEVHq9vfaTBmNsFlh1xt6WBe81h1ku1XiTorCAbuIMRiyNdWQ5swTqFTUAyh
	0wi0BAai94HjcnaoOBcfliJLqodqytm6S2nvn0jckR12gFgD8UW2rfsQS/WR4h9Eah/yKtnJCCGyD
	X579Lc9Jg==;
Received: from shell.armlinux.org.uk ([2001:4d48:ad52:3201:5054:ff:fe00:4ec]:56022)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1i3h3m-00075L-CF; Fri, 30 Aug 2019 14:35:26 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1i3h3i-0000A4-59; Fri, 30 Aug 2019 14:35:22 +0100
Date: Fri, 30 Aug 2019 14:35:22 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Jing Xiangfeng <jingxiangfeng@huawei.com>
Cc: ebiederm@xmission.com, kstewart@linuxfoundation.org,
	gregkh@linuxfoundation.org, gustavo@embeddedor.com,
	bhelgaas@google.com, tglx@linutronix.de,
	sakari.ailus@linux.intel.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] arm: fix page faults in do_alignment
Message-ID: <20190830133522.GZ13294@shell.armlinux.org.uk>
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
> The function do_alignment can handle misaligned address for user and
> kernel space. If it is a userspace access, do_alignment may fail on
> a low-memory situation, because page faults are disabled in
> probe_kernel_address.
> 
> Fix this by using __copy_from_user stead of probe_kernel_address.
> 
> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>

NAK.

The "scheduling while atomic warning in alignment handling code" is
caused by fixing up the page fault while trying to handle the
mis-alignment fault generated from an instruction in atomic context.

Your patch re-introduces that bug.

> ---
>  arch/arm/mm/alignment.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
> index 04b3643..2ccabd3 100644
> --- a/arch/arm/mm/alignment.c
> +++ b/arch/arm/mm/alignment.c
> @@ -774,6 +774,7 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
>  	unsigned long instr = 0, instrptr;
>  	int (*handler)(unsigned long addr, unsigned long instr, struct pt_regs *regs);
>  	unsigned int type;
> +	mm_segment_t fs;
>  	unsigned int fault;
>  	u16 tinstr = 0;
>  	int isize = 4;
> @@ -784,16 +785,22 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
>  
>  	instrptr = instruction_pointer(regs);
>  
> +	fs = get_fs();
> +	set_fs(KERNEL_DS);
>  	if (thumb_mode(regs)) {
>  		u16 *ptr = (u16 *)(instrptr & ~1);
> -		fault = probe_kernel_address(ptr, tinstr);
> +		fault = __copy_from_user(tinstr,
> +				(__force const void __user *)ptr,
> +				sizeof(tinstr));
>  		tinstr = __mem_to_opcode_thumb16(tinstr);
>  		if (!fault) {
>  			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
>  			    IS_T32(tinstr)) {
>  				/* Thumb-2 32-bit */
>  				u16 tinst2 = 0;
> -				fault = probe_kernel_address(ptr + 1, tinst2);
> +				fault = __copy_from_user(tinst2,
> +						(__force const void __user *)(ptr+1),
> +						sizeof(tinst2));
>  				tinst2 = __mem_to_opcode_thumb16(tinst2);
>  				instr = __opcode_thumb32_compose(tinstr, tinst2);
>  				thumb2_32b = 1;
> @@ -803,10 +810,13 @@ static ssize_t alignment_proc_write(struct file *file, const char __user *buffer
>  			}
>  		}
>  	} else {
> -		fault = probe_kernel_address((void *)instrptr, instr);
> +		fault = __copy_from_user(instr,
> +				(__force const void __user *)instrptr,
> +				sizeof(instr));
>  		instr = __mem_to_opcode_arm(instr);
>  	}
>  
> +	set_fs(fs);
>  	if (fault) {
>  		type = TYPE_FAULT;
>  		goto bad_or_fault;
> -- 
> 1.8.3.1
> 
> 

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

