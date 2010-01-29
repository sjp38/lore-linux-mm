Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 43D816B007B
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 23:44:45 -0500 (EST)
Date: Thu, 28 Jan 2010 20:43:24 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] DoS on x86_64
In-Reply-To: <4B621D48.4090203@zytor.com>
Message-ID: <alpine.LFD.2.00.1001282040160.3768@localhost.localdomain>
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org> <4B61B00D.7070202@zytor.com> <alpine.LFD.2.00.1001281427220.22433@localhost.localdomain> <4B62141E.4050107@zytor.com>
 <alpine.LFD.2.00.1001281507080.3846@localhost.localdomain> <4B621D48.4090203@zytor.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, security@kernel.org, "Luck, Tony" <tony.luck@intel.com>, James Morris <jmorris@namei.org>, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Mathias Krause <minipli@googlemail.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>



On Thu, 28 Jan 2010, H. Peter Anvin wrote:
> 
> I think your splitup patch might still be a good idea in the sense that
> your flush_old_exec() is the parts that can fail.
> 
> So I think the splitup patch, plus removing delayed effects, might be
> the right thing to do?  Testing that approach now...

So I didn't see any patch from you, so here's my try instead. 

I'll follow up with two patches: the first one does the split-up (and I 
tried to make it very obvious that it has _no_ semantic changes what-so- 
ever and is purely a preparatory patch), and the second actually changes 
the ELF loader to do the SET_PERSONALITY() call in the sane spot, and gets 
rid of that crazy indirect bit.

Comments?

It looks like ppc/sparc have had similar issues, I have _not_ done those 
architectures. I don't imagine that they'll complain much.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
