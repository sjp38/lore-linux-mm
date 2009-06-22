Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 58AD66B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:49:18 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <90774647-7bf6-4d54-bd39-e7ff74d055ab@default>
Date: Mon, 22 Jun 2009 13:50:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <4A3F95A6.5040503@nortel.com>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>


> > What if there was a class of memory that is of unknown
> > and dynamically variable size, is addressable only indirectly
> > by the kernel, can be configured either as persistent or
> > as "ephemeral" (meaning it will be around for awhile, but
> > might disappear without warning), and is still fast enough
> > to be synchronously accessible?
> >=20
> > We call this latter class "transcendent memory"
>=20
> While true that this memory is "exceeding usual limits", the more
> important criteria is that it may disappear.
>=20
> It might be clearer to just call it "ephemeral memory".

Ephemeral tmem (precache) may be the most interesting, but there
is persistent tmem (preswap) as well.  Both are working today
and both are included in the patches I posted.

Looking for a term encompassing both, I chose "transcendent".

> There is going to be some overhead due to the extra copying, and at
> times there could be two copies of data in memory.  It seems possible
> that certain apps right a the borderline could end up running slower
> because they can't fit in the regular+ephemeral memory due to the
> duplication, while the same amount of memory used normally could have
> been sufficient.

This is likely true, but I expect the duplicates to be few
and transient and a very small fraction of the total memory cost for
virtualization (and similar abstraction technologies).

> I suspect trying to optimize management of this could be difficult.

True.  Optimizing the management of ANY resource across many
consumers is difficult.  But wasting the resource because its
a pain to optimize doesn't seem to be a good answer either.

Thanks!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
