Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BADCF6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 11:52:29 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f126-v6so4304527lfg.5
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 08:52:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n7-v6sor1857095ljj.100.2018.06.08.08.52.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 08:52:27 -0700 (PDT)
Date: Fri, 8 Jun 2018 18:52:25 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Message-ID: <20180608155225.GC2525@uranus>
References: <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com>
 <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <CALCETrV1GG5rq_kwxkS-o3x8Ldr72ThdYgkJKQ9cx9Q63SxgTQ@mail.gmail.com>
 <CAMe9rOpeDrkwi-AG0vsiZy4NwkmavhB5Empv58FSHxtr3rpapw@mail.gmail.com>
 <CALCETrWhMmqGWKx-yw55YKHMJwGyLZio5f8Pskh8X69zfQMy7A@mail.gmail.com>
 <CAMe9rOpLDzWk=xdZqN1QJVnP-c_dti5Fy=C_GqbeQpS_a=0ewA@mail.gmail.com>
 <CALCETrUyapFiiXrHH23NW8XbqEkfKdGGU2wMUZ2DU=A+GWGqvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUyapFiiXrHH23NW8XbqEkfKdGGU2wMUZ2DU=A+GWGqvw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: "H. J. Lu" <hjl.tools@gmail.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Fri, Jun 08, 2018 at 07:57:22AM -0700, Andy Lutomirski wrote:
> On Fri, Jun 8, 2018 at 5:24 AM H.J. Lu <hjl.tools@gmail.com> wrote:
> >
> > On Thu, Jun 7, 2018 at 9:38 PM, Andy Lutomirski <luto@kernel.org> wrote:
> > > On Thu, Jun 7, 2018 at 9:10 PM H.J. Lu <hjl.tools@gmail.com> wrote:
> > >>
> > >> On Thu, Jun 7, 2018 at 4:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
> > >>
> > >
> > > By the time malicious code issue its own syscalls, you've already lost
> > > the battle.  I could probably be convinced that a lock-CET-on feature
> > > that applies *only* to the calling thread and is not inherited by
> > > clone() is a decent idea, but I'd want to see someone who understands
> > > the state of the art in exploit design justify it.  You're also going
> > > to need to figure out how to make CRIU work if you allow locking CET
> > > on.
> > >
> > > A priori, I think we should just not provide a lock mechanism.
> >
> > We need a door for CET.  But it is a very bad idea to leave it open
> > all the time.  I don't know much about CRIU,  If it is Checkpoint/Restore
> > In Userspace.  Can you free any application with AVX512 on AVX512
> > machine and restore it on non-AVX512 machine?
> 
> Presumably not -- if the program uses AVX512 and AVX512 goes away,
> then the program won't be happy.

Yes. In most scenarios we require the fpu capability to be the same
on both machines (in case of migration) or/and not being changed
between c/r cycles.
...
> As an aside, where are the latest CET docs?  I've found the "CET
> technology preview 2.0", but it doesn't seem to be very clear or
> entirely complete.

+1
