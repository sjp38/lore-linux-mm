Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EBE0C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C4B820650
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 15:18:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="NW9pkg/i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C4B820650
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D1006B0006; Fri,  6 Sep 2019 11:18:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A90E6B000D; Fri,  6 Sep 2019 11:18:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFF7D6B0271; Fri,  6 Sep 2019 11:18:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id CD0886B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 11:18:45 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 637441EF0
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:18:45 +0000 (UTC)
X-FDA: 75904853010.16.fang89_120ed86697b0d
X-HE-Tag: fang89_120ed86697b0d
X-Filterd-Recvd-Size: 9383
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk [78.32.30.218])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 15:18:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8bq46GmTKpsx8LOoXN7JFbaF/QCbZS6UaHK1xG4ulGU=; b=NW9pkg/ivCAestyk6uSCK0H/m
	sxoxvZ2uQIYHmbnGRazzc6qgfv1AWygDVfyBVWD7GDs0YomZ9UGYQULZK80oieqKBUucUEM5s0cKQ
	Bi3MyJ7qIemO0f9WFEqQ8AOJLa7mITeugvnWJnSLN6cVyPt7et7pEQD4BAFiM2YTX0vZHy9myMDZz
	vRxfd1Mo6JQek9xoEcSr33meD1Q7ivzqZwEWNItQgWc8u4Z6jwhZu0lb4aYb/gYtl0KUNyMfGwFv1
	9xFkzdc9IDpklxp8pLzylTm8gbMecdjRsuDRMO/kO6qBhj4AIm4gG9JO27eCWy0Jq3Gr1F2zphqG1
	KtwItiAbA==;
Received: from shell.armlinux.org.uk ([fd8f:7570:feb6:1:5054:ff:fe00:4ec]:40404)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1i6Fzy-0000vt-Uh; Fri, 06 Sep 2019 16:18:07 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1i6Fzr-0006Yo-Be; Fri, 06 Sep 2019 16:17:59 +0100
Date: Fri, 6 Sep 2019 16:17:59 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jing Xiangfeng <jingxiangfeng@huawei.com>, kstewart@linuxfoundation.org,
	gregkh@linuxfoundation.org, gustavo@embeddedor.com,
	bhelgaas@google.com, tglx@linutronix.de,
	sakari.ailus@linux.intel.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] arm: fix page faults in do_alignment
Message-ID: <20190906151759.GM13294@shell.armlinux.org.uk>
References: <1567171877-101949-1-git-send-email-jingxiangfeng@huawei.com>
 <20190830133522.GZ13294@shell.armlinux.org.uk>
 <87d0gmwi73.fsf@x220.int.ebiederm.org>
 <20190830203052.GG13294@shell.armlinux.org.uk>
 <87y2zav01z.fsf@x220.int.ebiederm.org>
 <20190830222906.GH13294@shell.armlinux.org.uk>
 <87mufmioqv.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mufmioqv.fsf@x220.int.ebiederm.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 12:36:56PM -0500, Eric W. Biederman wrote:
> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
> 
> > On Fri, Aug 30, 2019 at 04:02:48PM -0500, Eric W. Biederman wrote:
> >> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
> >> 
> >> > On Fri, Aug 30, 2019 at 02:45:36PM -0500, Eric W. Biederman wrote:
> >> >> Russell King - ARM Linux admin <linux@armlinux.org.uk> writes:
> >> >> 
> >> >> > On Fri, Aug 30, 2019 at 09:31:17PM +0800, Jing Xiangfeng wrote:
> >> >> >> The function do_alignment can handle misaligned address for user and
> >> >> >> kernel space. If it is a userspace access, do_alignment may fail on
> >> >> >> a low-memory situation, because page faults are disabled in
> >> >> >> probe_kernel_address.
> >> >> >> 
> >> >> >> Fix this by using __copy_from_user stead of probe_kernel_address.
> >> >> >> 
> >> >> >> Fixes: b255188 ("ARM: fix scheduling while atomic warning in alignment handling code")
> >> >> >> Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
> >> >> >
> >> >> > NAK.
> >> >> >
> >> >> > The "scheduling while atomic warning in alignment handling code" is
> >> >> > caused by fixing up the page fault while trying to handle the
> >> >> > mis-alignment fault generated from an instruction in atomic context.
> >> >> >
> >> >> > Your patch re-introduces that bug.
> >> >> 
> >> >> And the patch that fixed scheduling while atomic apparently introduced a
> >> >> regression.  Admittedly a regression that took 6 years to track down but
> >> >> still.
> >> >
> >> > Right, and given the number of years, we are trading one regression for
> >> > a different regression.  If we revert to the original code where we
> >> > fix up, we will end up with people complaining about a "new" regression
> >> > caused by reverting the previous fix.  Follow this policy and we just
> >> > end up constantly reverting the previous revert.
> >> >
> >> > The window is very small - the page in question will have had to have
> >> > instructions read from it immediately prior to the handler being entered,
> >> > and would have had to be made "old" before subsequently being unmapped.
> >> 
> >> > Rather than excessively complicating the code and making it even more
> >> > inefficient (as in your patch), we could instead retry executing the
> >> > instruction when we discover that the page is unavailable, which should
> >> > cause the page to be paged back in.
> >> 
> >> My patch does not introduce any inefficiencies.  It onlys moves the
> >> check for user_mode up a bit.  My patch did duplicate the code.
> >> 
> >> > If the page really is unavailable, the prefetch abort should cause a
> >> > SEGV to be raised, otherwise the re-execution should replace the page.
> >> >
> >> > The danger to that approach is we page it back in, and it gets paged
> >> > back out before we're able to read the instruction indefinitely.
> >> 
> >> I would think either a little code duplication or a function that looks
> >> at user_mode(regs) and picks the appropriate kind of copy to do would be
> >> the best way to go.  Because what needs to happen in the two cases for
> >> reading the instruction are almost completely different.
> >
> > That is what I mean.  I'd prefer to avoid that with the large chunk of
> > code.  How about instead adding a local replacement for
> > probe_kernel_address() that just sorts out the reading, rather than
> > duplicating all the code to deal with thumb fixup.
> 
> So something like this should be fine?
> 
> Jing Xiangfeng can you test this please?  I think this fixes your issue
> but I don't currently have an arm development box where I could test this.

Sorry, only just got around to this again.  What I came up with is this:

8<===
From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] ARM: mm: fix alignment

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 arch/arm/mm/alignment.c | 44 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 8 deletions(-)

diff --git a/arch/arm/mm/alignment.c b/arch/arm/mm/alignment.c
index 6067fa4de22b..529f54d94709 100644
--- a/arch/arm/mm/alignment.c
+++ b/arch/arm/mm/alignment.c
@@ -765,6 +765,36 @@ do_alignment_t32_to_handler(unsigned long *pinstr, struct pt_regs *regs,
 	return NULL;
 }
 
+static int alignment_get_arm(struct pt_regs *regs, u32 *ip, unsigned long *inst)
+{
+	u32 instr = 0;
+	int fault;
+
+	if (user_mode(regs))
+		fault = get_user(instr, ip);
+	else
+		fault = probe_kernel_address(ip, instr);
+
+	*inst = __mem_to_opcode_arm(instr);
+
+	return fault;
+}
+
+static int alignment_get_thumb(struct pt_regs *regs, u16 *ip, u16 *inst)
+{
+	u16 instr = 0;
+	int fault;
+
+	if (user_mode(regs))
+		fault = get_user(instr, ip);
+	else
+		fault = probe_kernel_address(ip, instr);
+
+	*inst = __mem_to_opcode_thumb16(instr);
+
+	return fault;
+}
+
 static int
 do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 {
@@ -772,10 +802,10 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 	unsigned long instr = 0, instrptr;
 	int (*handler)(unsigned long addr, unsigned long instr, struct pt_regs *regs);
 	unsigned int type;
-	unsigned int fault;
 	u16 tinstr = 0;
 	int isize = 4;
 	int thumb2_32b = 0;
+	int fault;
 
 	if (interrupts_enabled(regs))
 		local_irq_enable();
@@ -784,15 +814,14 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 
 	if (thumb_mode(regs)) {
 		u16 *ptr = (u16 *)(instrptr & ~1);
-		fault = probe_kernel_address(ptr, tinstr);
-		tinstr = __mem_to_opcode_thumb16(tinstr);
+
+		fault = alignment_get_thumb(regs, ptr, &tinstr);
 		if (!fault) {
 			if (cpu_architecture() >= CPU_ARCH_ARMv7 &&
 			    IS_T32(tinstr)) {
 				/* Thumb-2 32-bit */
-				u16 tinst2 = 0;
-				fault = probe_kernel_address(ptr + 1, tinst2);
-				tinst2 = __mem_to_opcode_thumb16(tinst2);
+				u16 tinst2;
+				fault = alignment_get_thumb(regs, ptr + 1, &tinst2);
 				instr = __opcode_thumb32_compose(tinstr, tinst2);
 				thumb2_32b = 1;
 			} else {
@@ -801,8 +830,7 @@ do_alignment(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 			}
 		}
 	} else {
-		fault = probe_kernel_address((void *)instrptr, instr);
-		instr = __mem_to_opcode_arm(instr);
+		fault = alignment_get_arm(regs, (void *)instrptr, &instr);
 	}
 
 	if (fault) {
-- 
2.7.4

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

