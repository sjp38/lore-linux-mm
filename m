Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF056B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:12:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q3so4032825pgv.16
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 02:12:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si2995286pfi.8.2017.11.30.02.12.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 02:12:38 -0800 (PST)
Date: Thu, 30 Nov 2017 11:12:29 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCHv2 0/4] x86: 5-level related changes into decompression
 code
Message-ID: <20171130101229.b6wqlesgwvx7xg6e@pd.tnic>
References: <20171129154908.6y4st6xc7hbsey2v@pd.tnic>
 <20171129161349.d7ksuhwhdamloty6@node.shutemov.name>
 <alpine.DEB.2.20.1711291740050.1825@nanos>
 <20171129170831.2iqpop2u534mgrbc@node.shutemov.name>
 <20171129174851.jk2ai37uumxve6sg@pd.tnic>
 <793b9c55-e85b-97b5-c857-dd8edcda4081@zytor.com>
 <20171129191902.2iamm3m23e3gwnj4@pd.tnic>
 <e4463396-9b7c-2fe8-534c-73820c0bce5f@zytor.com>
 <20171129223103.in4qmtxbj2sawhpw@pd.tnic>
 <f0c0db4a-6196-d36d-cd1e-8dfc9c09767a@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <f0c0db4a-6196-d36d-cd1e-8dfc9c09767a@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 29, 2017 at 03:24:53PM -0800, H. Peter Anvin wrote:
> Yes, Grub as a matter of policy(!) does everything in the most braindead
> way possible.  You have to use "linux16" or "linuxefi" to make it do
> something sane.

Good to know, thx.

> What is text mode?  It is hardware that is going away(*), and you don't
> even know if you have a display screen on your system at all, or how
> you'd have to configure your display hardware even if it is "mostly" VGA.

Ok, let me take a stab completely in the dark here: can we ask FW to
switch to some mode which is "suitable" for printing messages?

It would mean we'd have to switch back to real mode where we could do
something ala arch/x86/boot/bioscall.S

After we've printed something, we halt.

If there's no screen, we only halt - it's not like we can magically get
a fairy to connect a screen to the system.

> Well, it's not just limited to 5-level mode; it's kind a general issue.
> We have had this issue for a very, very long time -- all the way back to
> i386 PAE at the very least.

I realize that, judging by your reaction. And yes, we should try to find
a proper solution here in the long run.

> I'm personally OK with triple-faulting the CPU in this case.

Except that is not really user-friendly, as I mentioned already, and
could save other users a bunch of time looking for why TF the kernel
doesn't boot only to realize they enabled an option which is not ready
yet. Which should have depended on BROKEN when it went upstream, btw.

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
