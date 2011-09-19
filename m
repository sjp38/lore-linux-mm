Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id DA8AF9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 15:20:18 -0400 (EDT)
Received: by gwm11 with SMTP id 11so6355373gwm.30
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 12:20:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110919185518.GA5563@albatros>
References: <20110919144657.GA5928@albatros>
	<CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
	<20110919155718.GB16272@albatros>
	<CAOJsxLGZm+npcR0YgXSE2wLC2iXCtzYyCdTDCt1LN=Z28Rm_UA@mail.gmail.com>
	<20110919161837.GA2232@albatros>
	<CAOJsxLE2od0f+6cbL2hA_31CbrqS7AUofx5DT2L9fO_7gxH+PQ@mail.gmail.com>
	<20110919173539.GA3751@albatros>
	<CAOJsxLGc0bwCkDtk2PVe7c155a9wVoDAY0CmYDTLg8_bL4qxqg@mail.gmail.com>
	<20110919175856.GA4282@albatros>
	<CAOJsxLFdNVnW6Faap0UaqZQDQxbA_dEiR2HGdzZtGMJFsVR1WQ@mail.gmail.com>
	<20110919185518.GA5563@albatros>
Date: Mon, 19 Sep 2011 22:20:16 +0300
Message-ID: <CAOJsxLHWu7gm94MvFOcbrjW33AqpD7i+kYL1+mEMt=4cS53GhA@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Sep 19, 2011 at 9:55 PM, Vasiliy Kulikov <segoon@openwall.com> wrot=
e:
> Oh, we also have perf... =A0Given these are separate interfaces, I think
> slab oriented restriction makes more sense.
>
> So, now we have:
>
> /proc/slabinfo
> /sys/kernel/slab
> /proc/meminfo
> 'perf kmem' - not sure what specific files should be guarded

I don't think you can close down 'perf kmem' per se. You need to make
sure the attacker is not able to use perf tracing (of which 'perf kmem' is
a subset).

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
