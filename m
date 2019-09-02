Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A03F7C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 17:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E1420644
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 17:37:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E1420644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A935A6B0005; Mon,  2 Sep 2019 13:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1CBC6B0006; Mon,  2 Sep 2019 13:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDB96B0007; Mon,  2 Sep 2019 13:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id 67D336B0005
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 13:37:17 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0B7CE181AC9B6
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 17:37:17 +0000 (UTC)
X-FDA: 75890686914.22.sleet83_79ab49c4fc250
X-HE-Tag: sleet83_79ab49c4fc250
X-Filterd-Recvd-Size: 9598
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 17:37:15 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
	by out03.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.87)
	(envelope-from <ebiederm@xmission.com>)
	id 1i4qGO-0002zA-3H; Mon, 02 Sep 2019 11:37:12 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=x220.xmission.com)
	by in02.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.87)
	(envelope-from <ebiederm@xmission.com>)
	id 1i4qGM-0001qg-UC; Mon, 02 Sep 2019 11:37:11 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>
Cc: Jing Xiangfeng <jingxiangfeng@huawei.com>,  kstewart@linuxfoundation.org,  gregkh@linuxfoundation.org,  gustavo@embeddedor.com,  bhelgaas@google.com,  tglx@linutronix.de,  sakari.ailus@linux.intel.com,  linux-arm-kernel@lists.infradead.org,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
	<20190830133522.GZ13294@shell.armlinux.org.uk>
	<87d0gmwi73.fsf@x220.int.ebiederm.org>
	<20190830203052.GG13294@shell.armlinux.org.uk>
	<87y2zav01z.fsf@x220.int.ebiederm.org>
	<20190830222906.GH13294@shell.armlinux.org.uk>
Date: Mon, 02 Sep 2019 12:36:56 -0500
In-Reply-To: <20190830222906.GH13294@shell.armlinux.org.uk> (Russell King's
	message of "Fri, 30 Aug 2019 23:29:06 +0100")
Message-ID: <87mufmioqv.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1i4qGM-0001qg-UC;;;mid=<87mufmioqv.fsf@x220.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX19m9YGitx9H8/ZuABLUqkLN/nGTTjlMCgw=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH] arm: fix page faults in do_alignment
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:

> On Fri, Aug 30, 2019 at 04:02:48PM -0500, Eric W. Biederman wrote:
>> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
>> 
>> > On Fri, Aug 30, 2019 at 02:45:36PM -0500, Eric W. Biederman wrote:
>> >> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
>> >> 
>> >> > On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
>> >> >> The function do_alignment can handle misaligned address for user and
>> >> >> kernel space. If it is a userspace access, do_alignment may fail on
>> >> >> a low-memory situation, because page faults are disabled in
>> >> >> probe_kernel_address.
>> >> >> 
>> >> >> Fix this by using __copy_from_user stead of probe_kernel_address.
>> >> >> 
>> >> >> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
>> >> >> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
>> >> >
>> >> > NAK.
>> >> >
>> >> > The "scheduling while atomic warning in alignment handling code" is
>> >> > caused by fixing up the page fault while trying to handle the
>> >> > mis-alignment fault generated from an instruction in atomic context.
>> >> >
>> >> > Your patch re-introduces that bug.
>> >> 
>> >> And the patch that fixed scheduling while atomic apparently introduced a
>> >> regression.  Admittedly a regression that took 6 years to track down but
>> >> still.
>> >
>> > Right, and given the number of years, we are trading one regression for
>> > a different regression.  If we revert to the original code where we
>> > fix up, we will end up with people complaining about a "new" regression
>> > caused by reverting the previous fix.  Follow this policy and we just
>> > end up constantly reverting the previous revert.
>> >
>> > The window is very small - the page in question will have had to have
>> > instructions read from it immediately prior to the handler being entered,
>> > and would have had to be made "old" before subsequently being unmapped.
>> 
>> > Rather than excessively complicating the code and making it even more
>> > inefficient (as in your patch), we could instead retry executing the
>> > instruction when we discover that the page is unavailable, which should
>> > cause the page to be paged back in.
>> 
>> My patch does not introduce any inefficiencies.  It onlys moves the
>> check for user_mode up a bit.  My patch did duplicate the code.
>> 
>> > If the page really is unavailable, the prefetch abort should cause a
>> > SEGV to be raised, otherwise the re-execution should replace the page.
>> >
>> > The danger to that approach is we page it back in, and it gets paged
>> > back out before we're able to read the instruction indefinitely.
>> 
>> I would think either a little code duplication or a function that looks
>> at user_mode(regs) and picks the appropriate kind of copy to do would be
>> the best way to go.  Because what needs to happen in the two cases for
>> reading the instruction are almost completely different.
>
> That is what I mean.  I'd prefer to avoid that with the large chunk of
> code.  How about instead adding a local replacement for
> probe_kernel_address() that just sorts out the reading, rather than
> duplicating all the code to deal with thumb fixup.

So something like this should be fine?

Jing Xiangfeng can you test this please?  I think this fixes your issue
but I don't currently have an arm development box where I could test this.

diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index 04b36436cbc0..b07d17ca0ae5 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -767,6 +767,23 @@ do_alignment_t32_to_handler(unsigned long *pinstr, struct pt_regs *regs,
 	return NULL;
 }
 
+static inline unsigned long
+copy_instr(bool umode, void *dst, unsigned long instrptr, size_t size)
+{
+	unsigned long result;
+	if (umode) {
+		void __user *src = (void *)instrptr;
+		result = copy_from_user(dst, src, size);
+	} else {
+		void *src = (void *)instrptr;
+		result = probe_kernel_read(dst, src, size);
+	}
+	/* Convert short reads into -EFAULT */
+	if ((result >= 0) && (result < size))
+		result = -EFAULT;
+	return result;
+}
+
 static int
 do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 {
@@ -778,22 +795,24 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	u16 tinstr = 0;
 	int isize = 4;
 	int thumb2_32b = 0;
+	bool umode;
 
 	if (interrupts_enabled(regs))
 		local_irq_enable();
 
 	instrptr = instruction_pointer(regs);
+	umode = user_mode(regs);
 
 	if (thumb_mode(regs)) {
-		u16 *ptr = (u16 *)(instrptr & ~1);
-		fault = probe_kernel_address(ptr, tinstr);
+		unsigned long tinstrptr = instrptr & ~1;
+		fault = copy_instr(umode, &tinstr, tinstrptr, 2);
 		tinstr = __mem_to_opcode_thumb16(tinstr);
 		if (!fault) {
 			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
 			    IS_T32(tinstr)) {
 				/* Thumb-2 32-bit */
 				u16 tinst2 = 0;
-				fault = probe_kernel_address(ptr + 1, tinst2);
+				fault = copy_instr(umode, &tinst2, tinstrptr + 2, 2);
 				tinst2 = __mem_to_opcode_thumb16(tinst2);
 				instr = __opcode_thumb32_compose(tinstr, tinst2);
 				thumb2_32b = 1;
@@ -803,7 +822,7 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 			}
 		}
 	} else {
-		fault = probe_kernel_address((void *)instrptr, instr);
+		fault = copy_instr(umode, &instr, instrptr, 4);
 		instr = __mem_to_opcode_arm(instr);
 	}
 
@@ -812,7 +831,7 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		goto bad_or_fault;
 	}
 
-	if (user_mode(regs))
+	if (umode)
 		goto user;
 
 	ai_sys += 1;

