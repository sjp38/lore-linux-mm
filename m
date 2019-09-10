Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE8D4C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A84220872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:17:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="MvjVDPw8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A84220872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D3076B026A; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8841D6B026B; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 612156B026F; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0219.hostedemail.com [216.40.44.219])
	by kanga.kvack.org (Postfix) with ESMTP id 394486B026A
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:17:20 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E23CA180AD801
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:19 +0000 (UTC)
X-FDA: 75918457398.17.trees64_5bcf9393a64e
X-HE-Tag: trees64_5bcf9393a64e
X-Filterd-Recvd-Size: 5466
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:17:19 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46SKDY1QD0z9txWC;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=MvjVDPw8; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Msu_dKvgM-Ra; Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46SKDY0Nzwz9txW3;
	Tue, 10 Sep 2019 11:17:17 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568107037; bh=8QgIQ71YTNVzSY6FhAVflXh/3XEeMxBtSGOEfNUDtow=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=MvjVDPw8MVX+S1wuojufmKnez0Dc0cwN4FoPPXEzuZup7GQZDpohfKH0on0JVc+kt
	 tDT3x4RY4Zd0jEVVT0e+/yFMqlV2fv9KY8mDZpD25Bbm8VmoweLCBrGuugfJjq9geI
	 Ro6igU02YJHHCrG2rFhXrhVZbQQhD9SDoswJrjJw=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id D720B8B881;
	Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id J-LvfglUaSA7; Tue, 10 Sep 2019 11:17:15 +0200 (CEST)
Received: from pc16032vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B44D98B896;
	Tue, 10 Sep 2019 11:16:29 +0200 (CEST)
Received: by pc16032vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 420F56B739; Tue, 10 Sep 2019 09:16:29 +0000 (UTC)
Message-Id: <afee0f68dbfa72785457fd13f15f6fd5e249264d.1568106758.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1568106758.git.christophe.leroy@c-s.fr>
References: <cover.1568106758.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v3 10/15] powerpc/8xx: drop exception entries for non-existing
 exceptions
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
    npiggin@gmail.com,
    dja@axtens.net
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
    linux-mm@kvack.org
Date: Tue, 10 Sep 2019 09:16:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

head_8xx.S has entries for all exceptions from 0x100 to 0x1f00.
Several of them do not exist and are never generated by the 8xx
in accordance with the documentation.

Remove those entry points to make some room for future growing
exception code.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/kernel/head_8xx.S | 29 -----------------------------
 1 file changed, 29 deletions(-)

diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
index 3de9c5f1746c..5aa63693f790 100644
--- a/arch/powerpc/kernel/head_8xx.S
+++ b/arch/powerpc/kernel/head_8xx.S
@@ -134,18 +134,6 @@ MachineCheck:
 	addi r3,r1,STACK_FRAME_OVERHEAD
 	EXC_XFER_STD(0x200, machine_check_exception)
 
-/* Data access exception.
- * This is "never generated" by the MPC8xx.
- */
-	. = 0x300
-DataAccess:
-
-/* Instruction access exception.
- * This is "never generated" by the MPC8xx.
- */
-	. = 0x400
-InstructionAccess:
-
 /* External interrupt */
 	EXCEPTION(0x500, HardwareInterrupt, do_IRQ, EXC_XFER_LITE)
 
@@ -162,16 +150,9 @@ Alignment:
 /* Program check exception */
 	EXCEPTION(0x700, ProgramCheck, program_check_exception, EXC_XFER_STD)
 
-/* No FPU on MPC8xx.  This exception is not supposed to happen.
-*/
-	EXCEPTION(0x800, FPUnavailable, unknown_exception, EXC_XFER_STD)
-
 /* Decrementer */
 	EXCEPTION(0x900, Decrementer, timer_interrupt, EXC_XFER_LITE)
 
-	EXCEPTION(0xa00, Trap_0a, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0xb00, Trap_0b, unknown_exception, EXC_XFER_STD)
-
 /* System call */
 	. = 0xc00
 SystemCall:
@@ -179,8 +160,6 @@ SystemCall:
 
 /* Single step - not used on 601 */
 	EXCEPTION(0xd00, SingleStep, single_step_exception, EXC_XFER_STD)
-	EXCEPTION(0xe00, Trap_0e, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0xf00, Trap_0f, unknown_exception, EXC_XFER_STD)
 
 /* On the MPC8xx, this is a software emulation interrupt.  It occurs
  * for all unimplemented and illegal instructions.
@@ -507,14 +486,6 @@ DARFixed:/* Return from dcbx instruction bug workaround */
 	/* 0x300 is DataAccess exception, needed by bad_page_fault() */
 	EXC_XFER_LITE(0x300, handle_page_fault)
 
-	EXCEPTION(0x1500, Trap_15, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0x1600, Trap_16, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0x1700, Trap_17, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0x1800, Trap_18, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0x1900, Trap_19, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0x1a00, Trap_1a, unknown_exception, EXC_XFER_STD)
-	EXCEPTION(0x1b00, Trap_1b, unknown_exception, EXC_XFER_STD)
-
 /* On the MPC8xx, these next four traps are used for development
  * support of breakpoints and such.  Someday I will get around to
  * using them.
-- 
2.13.3


