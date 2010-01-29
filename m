Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AB16F6B007E
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 00:30:13 -0500 (EST)
Message-ID: <4B627236.1040508@zytor.com>
Date: Thu, 28 Jan 2010 21:29:26 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [Security] DoS on x86_64
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com> <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com> <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

Here is a cleaned-up version of my patches... I pretty much used your
descriptions straight off.  The first one is your original split patch
with my (small) changes folded in, the second one is my removal of
TIF_ABI_PENDING.

The main difference, again, is that my variant sets the personality
*before* calling setup_new_exec().

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
