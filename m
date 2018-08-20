Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6BFF6B1B6F
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 18:28:04 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id r206-v6so10653648iod.2
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 15:28:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k195-v6sor348023ith.64.2018.08.20.15.28.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 15:28:03 -0700 (PDT)
MIME-Version: 1.0
References: <20180820212556.GC2230@char.us.oracle.com> <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk>
In-Reply-To: <1534801939.10027.24.camel@amazon.co.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 20 Aug 2018 15:27:52 -0700
Message-ID: <CA+55aFxyUdhYjnQdnmWAt8tTwn4HQ1xz3SAMZJiawkLpMiJ_+w@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw@amazon.co.uk>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, Khalid Aziz <khalid.aziz@oracle.com>, kanth.ghatraju@oracle.com, Liran Alon <liran.alon@oracle.com>, Kees Cook <keescook@google.com>, jsteckli@os.inf.tu-dresden.de, Kernel Hardening <kernel-hardening@lists.openwall.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, John Haxby <john.haxby@oracle.com>, Jon Masters <jcm@redhat.com>

On Mon, Aug 20, 2018 at 3:02 PM Woodhouse, David <dwmw@amazon.co.uk> wrote:
>
> It's the *kernel* we don't want being able to access those pages,
> because of the multitude of unfixable cache load gadgets.

Ahh.

I guess the proof is in the pudding. Did somebody try to forward-port
that patch set and see what the performance is like?

It used to be just 500 LOC. Was that because they took horrible
shortcuts? Are the performance numbers for the 32-bit case that
already had the kmap() overhead?

                  Linus
