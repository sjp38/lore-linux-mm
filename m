Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 260DA9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 14:56:04 -0400 (EDT)
Received: by wyh13 with SMTP id 13so7424551wyh.30
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 11:56:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLFdNVnW6Faap0UaqZQDQxbA_dEiR2HGdzZtGMJFsVR1WQ@mail.gmail.com>
References: <20110918170512.GA2351@albatros> <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
 <20110919144657.GA5928@albatros> <CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
 <20110919155718.GB16272@albatros> <CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com>
 <20110919161837.GA2232@albatros> <CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com>
 <20110919173539.GA3751@albatros> <CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
 <20110919175856.GA4282@albatros> <CAOJsxLFdNVnW6Faap0UaqZQDQxbA_dEiR2HGdzZtGMJFsVR1WQ@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Sep 2011 11:55:42 -0700
Message-ID: <CA+55aFwnxOvkS12i97kJcWFrH7n591vxq7vBXKzuROiirnYJ0g@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Vasiliy Kulikov <segoon@openwall.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>

On Mon, Sep 19, 2011 at 11:46 AM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
>
> OK, so what about /proc/meminfo, sysfs, 'perf kmem', and other kernel interfaces
> through which you can get direct or indirect information about kernel memory
> allocations?

Pekka, there are degrees of badness.

Also, quite frankly, your argument that /proc/slabinfo is so important
for kernel debugging is bogus. Every time I've complained about the
fact that the thing is useless AND ACTIVELY MISLEADING because it
mixes up all the slabs (so big numbers for "vm_area_struct" might
actually be about some other slab entirely, and *has* been, to the
point of people wasting time), the answer has been "whatever".

You can't have it both ways just to argue for the status quo.

Considering how useless /proc/slabinfo actually is today - exactly
because of the misleading mixing - I suspect the right thing to do is
to make it root-only.

Having some aggregate number in /proc/meminfo would probably be fine.

And yes, we probably should avoid giving page-level granularity in
/proc/meminfo too. Do it in megabytes instead. None of the information
there is really relevant at a page level, everybody just wants rough
aggregates.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
