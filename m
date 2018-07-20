Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1AC06B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 03:59:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e19-v6so5409985pgv.11
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 00:59:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v129-v6si1189530pgv.610.2018.07.20.00.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 00:59:46 -0700 (PDT)
Date: Fri, 20 Jul 2018 09:59:33 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 00/39 v8] PTI support for x86-32
Message-ID: <20180720075933.fegnjnhgouclitft@suse.de>
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <alpine.DEB.2.21.1807200114130.1693@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807200114130.1693@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

Hi Thomas,

On Fri, Jul 20, 2018 at 01:21:33AM +0200, Thomas Gleixner wrote:
> On Wed, 18 Jul 2018, Joerg Roedel wrote:
> > 
> > here is version 8 of my patches to enable PTI on x86-32. The
> > last version got some good review which I mostly worked into
> > this version.
> 
> I went over the whole set once again and did not find any real issues. As
> the outstanding review comments are addressed, I decided that only broader
> exposure can shake out eventually remaining issues. Applied and pushed out,
> so it should show up in linux-next soon.
> 
> The mm regression seems to be sorted, so there is no immeditate fallout
> expected.
> 
> Thanks for your patience in reworking this over and over. Thanks to Andy
> for putting his entry focssed eyes on it more than once. Great work!

Thanks a lot too! Let's hope things will go smooth from here...
I will also continue testing and improving the code, currently I am
working on a relaxed paranoid entry/exit path suggested by Andy.


Regards,

	Joerg
