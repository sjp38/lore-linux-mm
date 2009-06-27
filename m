Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 336EE6B004D
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 09:18:24 -0400 (EDT)
Received: by bwz21 with SMTP id 21so3370901bwz.38
        for <linux-mm@kvack.org>; Sat, 27 Jun 2009 06:18:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
References: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Date: Sat, 27 Jun 2009 15:18:55 +0200
Message-ID: <63386a3d0906270618h5be01265v759f5acd1f49682f@mail.gmail.com>
Subject: Re: [RFC] transcendent memory for Linux
From: Linus Walleij <linus.ml.walleij@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, linux-embedded@vger.kernel.org
List-ID: <linux-mm.kvack.org>

2009/6/20 Dan Magenheimer <dan.magenheimer@oracle.com>:

> We call this latter class "transcendent memory" and it
> provides an interesting opportunity to more efficiently
> utilize RAM in a virtualized environment. =A0However this
> "memory but not really memory" may also have applications
> in NON-virtualized environments, such as hotplug-memory
> deletion, SSDs, and page cache compression. =A0Others have
> suggested ideas such as allowing use of highmem memory
> without a highmem kernel, or use of spare video memory.

Here is what I consider may be a use case from the embedded
world: we have to save power as much as possible, so we need
to shut off entire banks of memory.

Currently people do things like put memory into self-refresh
and then sleep, but for long lapses of time you would
want to compress memory towards lower addresses and
turn as many banks as possible off.

So we have something like 4x16MB banks of RAM =3D 64MB RAM,
and the most necessary stuff easily fits in one of them.
If we can shut down 3x16MB we save 3 x power supply of the
RAMs.

However in embedded we don't have any swap, so we'd need
some call that would attempt to remove a memory by paging
out code and data that has been demand-paged in
from the FS but no dirty pages, these should instead be
moved down to memory which will be retained, and the
call should fail if we didn't succeed to migrate all
dirty pages.

Would this be possible with transcendent memory?

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
