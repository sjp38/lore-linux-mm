Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 768D76B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:56:26 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id w198so4937584qka.3
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:56:26 -0800 (PST)
Received: from smtp-fw-6001.amazon.com (smtp-fw-6001.amazon.com. [52.95.48.154])
        by mx.google.com with ESMTPS id n70si5111452qka.337.2017.11.30.10.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 10:56:25 -0800 (PST)
Date: Thu, 30 Nov 2017 10:56:04 -0800
From: Eduardo Valentin <eduval@amazon.com>
Subject: [RESEND] Kaiser backport to stable v4.9.y
Message-ID: <20171130185604.GA18265@u40b0340c692b58f6553c.ant.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, stable@vger.kernel.org, Andy
 Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Eduardo
 Valentin <eduval@amazon.com>, Peter Zijlstra <peterz@infradead.org>, gregkh@linuxfoundation.org
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys
 Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh
 Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, aliguori@amazon.com

Hello, 

(correcting stable tree mailing list address and add GregKH)

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
