Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 013D36B1B53
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 18:36:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5-v6so6852155pgs.13
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 15:36:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r5-v6sor2494979pgn.106.2018.08.20.15.36.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 15:36:01 -0700 (PDT)
Date: Mon, 20 Aug 2018 16:35:57 -0600
From: Tycho Andersen <tycho@tycho.ws>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Message-ID: <20180820223557.GC16961@cisco.cisco.com>
References: <20180820212556.GC2230@char.us.oracle.com>
 <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
 <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Woodhouse <dwmw@amazon.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, jsteckli@os.inf.tu-dresden.de, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On Mon, Aug 20, 2018 at 03:27:52PM -0700, Linus Torvalds wrote:
> On Mon, Aug 20, 2018 at 3:02 PM Woodhouse, David <dwmw@amazon.co.uk> wrote:
> >
> > It's the *kernel* we don't want being able to access those pages,
> > because of the multitude of unfixable cache load gadgets.
> 
> Ahh.
> 
> I guess the proof is in the pudding. Did somebody try to forward-port
> that patch set and see what the performance is like?
> 
> It used to be just 500 LOC. Was that because they took horrible
> shortcuts? Are the performance numbers for the 32-bit case that
> already had the kmap() overhead?

The last version I worked on was a bit before Meltdown was public:
https://lkml.org/lkml/2017/9/7/445

The overhead was a lot, but Dave Hansen gave some ideas about how to
speed things up in this thread: https://lkml.org/lkml/2017/9/20/828

Since meltdown hit, I haven't worked seriously on understand and
implementing his suggestions, in part because it wasn't clear to me
what pieces of the infrastructure we might be able to re-use. Someone
who knows more about mm/ might be able to suggest an approach, though.

Tycho
