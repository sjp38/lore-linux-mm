Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A80B36B1B48
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 18:18:22 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id u125-v6so2926665ywf.19
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 15:18:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r126-v6sor2457968ywd.144.2018.08.20.15.18.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 15:18:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1534801939.10027.24.camel@amazon.co.uk>
References: <20180820212556.GC2230@char.us.oracle.com> <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
From: Kees Cook <keescook@google.com>
Date: Mon, 20 Aug 2018 15:18:20 -0700
Message-ID: <CAGXu5jLSPGe7W0qpUYoQr4C-Yy5FV8Q=hUKRYO9zSbeUNSZn0g@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Woodhouse, David" <dwmw@amazon.co.uk>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "juerg.haefliger@hpe.com" <juerg.haefliger@hpe.com>, "deepa.srinivasan@oracle.com" <deepa.srinivasan@oracle.com>, "jmattson@google.com" <jmattson@google.com>, "andrew.cooper3@citrix.com" <andrew.cooper3@citrix.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>, "pradeep.vincent@oracle.com" <pradeep.vincent@oracle.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "kanth.ghatraju@oracle.com" <kanth.ghatraju@oracle.com>, "liran.alon@oracle.com" <liran.alon@oracle.com>, "jsteckli@os.inf.tu-dresden.de" <jsteckli@os.inf.tu-dresden.de>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "chris.hyser@oracle.com" <chris.hyser@oracle.com>, "tyhicks@canonical.com" <tyhicks@canonical.com>, "john.haxby@oracle.com" <john.haxby@oracle.com>, "jcm@redhat.com" <jcm@redhat.com>

On Mon, Aug 20, 2018 at 2:52 PM, Woodhouse, David <dwmw@amazon.co.uk> wrote:
> On Mon, 2018-08-20 at 14:48 -0700, Linus Torvalds wrote:
>>
>> Of course, after the long (and entirely unrelated) discussion about
>> the TLB flushing bug we had, I'm starting to worry about my own
>> competence, and maybe I'm missing something really fundamental, and
>> the XPFO patches do something else than what I think they do, or my
>> "hey, let's use our Meltdown code" idea has some fundamental weakness
>> that I'm missing.
>
> The interesting part is taking the user (and other) pages out of the
> kernel's 1:1 physmap.
>
> It's the *kernel* we don't want being able to access those pages,
> because of the multitude of unfixable cache load gadgets.

Right. And even before Meltdown, it was desirable to remove those from
the physmap to avoid SMAP (and in some cases SMEP) bypasses (as
detailed in the mentioned paper:
http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf).

-Kees

-- 
Kees Cook
Pixel Security
