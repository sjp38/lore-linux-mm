Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE458E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 21:03:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d132-v6so1611475pgc.22
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 18:03:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t190-v6sor1819369pgd.413.2018.09.18.18.03.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 18:03:42 -0700 (PDT)
Date: Wed, 19 Sep 2018 11:03:37 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Message-ID: <20180919010337.GC8537@350D>
References: <20180820212556.GC2230@char.us.oracle.com>
 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534801939.10027.24.camel@amazon.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Woodhouse, David" <dwmw@amazon.co.uk>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "keescook@google.com" <keescook@google.com>, "jsteckli@os.inf.tu-dresden.de" <jsteckli@os.inf.tu-dresden.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

On Mon, Aug 20, 2018 at 09:52:19PM +0000, Woodhouse, David wrote:
> On Mon, 2018-08-20 at 14:48 -0700, Linus Torvalds wrote:
> > 
> > Of course, after the long (and entirely unrelated) discussion about
> > the TLB flushing bug we had, I'm starting to worry about my own
> > competence, and maybe I'm missing something really fundamental, and
> > the XPFO patches do something else than what I think they do, or my
> > "hey, let's use our Meltdown code" idea has some fundamental weakness
> > that I'm missing.
> 
> The interesting part is taking the user (and other) pages out of the
> kernel's 1:1 physmap.
> 
> It's the *kernel* we don't want being able to access those pages,
> because of the multitude of unfixable cache load gadgets.

I am missing why we need this since the kernel can't access
(SMAP) unless we go through to the copy/to/from interface
or execute any of the user pages. Is it because of the dependency
on the availability of those features?

Balbir Singh.
