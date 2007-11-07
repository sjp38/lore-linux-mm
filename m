Date: Wed, 7 Nov 2007 11:00:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 14/23] inodes: Support generic defragmentation
In-Reply-To: <20071107185113.GC8918@lazybastard.org>
Message-ID: <Pine.LNX.4.64.0711071056380.12363@schroedinger.engr.sgi.com>
References: <20071107011130.382244340@sgi.com> <20071107011229.893091119@sgi.com>
 <20071107101748.GC7374@lazybastard.org> <Pine.LNX.4.64.0711071035490.9857@schroedinger.engr.sgi.com>
 <20071107185113.GC8918@lazybastard.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-1824650294-1194462012=:12363"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Cc: akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

---1700579579-1824650294-1194462012=:12363
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 7 Nov 2007, J=F6rn Engel wrote:

> > The pointer is for communication between the get and kick methods. get(=
)=20
> > can  modify kick() behavior by returning a pointer to a data structure =
or=20
> > using the pointer to set a flag. F.e. get() may discover that there is =
an=20
> > unreclaimable object and set a flag that causes kick to simply undo the=
=20
> > refcount increment. get() may build a map for the objects and indicate =
in=20
> > the map special treatment.=20
>=20
> Is there a get/kick pair that actually does this?  So far I haven't
> found anything like it.

Hmmm.. Nothing uses it at this point. I went through a series of get/kicks
during development. Some needed it. I suspect that we will need it when we=
=20
implement reallocation instead of simply reclaiming. It is also necessary
if we get into the situation where we want to optimize the reclaim. At=20
that point the kick method needs to know how far get() got before the=20
action was aborted in order to fix up only certain refcounts.

> Also, something vaguely matching that paragraph might make sense in a
> kerneldoc header to the function. ;)

Its described in slab.h

---1700579579-1824650294-1194462012=:12363--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
