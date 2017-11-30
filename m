Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AABF6B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:48:28 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id j7so4740033pgv.20
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:48:28 -0800 (PST)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.190.10])
        by mx.google.com with ESMTPS id i1si3423199pgp.722.2017.11.30.10.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 10:48:27 -0800 (PST)
Date: Thu, 30 Nov 2017 10:48:12 -0800
From: Eduardo Valentin <eduval@amazon.com>
Subject: Kaiser backport to stable v4.9.y
Message-ID: <20171130184812.GD435@u40b0340c692b58f6553c.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.amazon.com, Dave Hansen <dave.hansen@linux.intel.com>, Andy
 Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys
 Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh
 Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, aliguori@amazon.com

Hello, 

I have created this branch with the KAISER patches and dependencies to v4.9.y.
This is massive, I know. But I attempted to include all dependencies I saw
in the mailing list discussions. The backport is done from the tip/WIP.x86/mm
branch. The list of patches include:
a. Several patch dependencies that change x86 arch code so following applies.
b. Andy Lutomirski work to refactor the x86 entry code.
c. Andy Lutomirski work to do the x86 trampolim.
d. Dave Handen's work to incorporate the KAISER feature on x86.
e. Several fixes/improvements on KAISER by tglx and PeterZ.

Branch is here:
https://git.kernel.org/pub/scm/linux/kernel/git/evalenti/linux.git/log/?h=backports/v4.9.y/x86/kaiser

Right now, I am still validating it under different scenarios. First shot on
the same lseek1 [1] micro bench, a see the Kernel being ~4x slower:
-> Without KAISER: ~14Mlseek/s.
-> With KAISER: ~3.6Mlseek/s.

If anybody is interested in testing please send feedback. 
Also, if somebody else is working on a minimalist backport of the feature
to v4.9 or other stable kernels, let me know.

[1] - https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c/
-- 
All the best,
Eduardo Valentin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
