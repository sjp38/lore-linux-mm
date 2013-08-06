Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 67AF46B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 12:26:43 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id eh20so1349686obb.15
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 09:26:42 -0700 (PDT)
Date: Tue, 6 Aug 2013 11:26:40 -0500
From: Eric Boxer <boxerspam1@gmail.com>
Message-ID: <088AF050-3C88-4FBD-9004-33C7AFFC1517@gmail.com>
In-Reply-To: <CAJfpegtr4+vv_ZzuM7EE7MkHPqNi4brQamg4ZOWb2Me+iG87JQ@mail.gmail.com>
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru>
 <20130629174525.20175.18987.stgit@maximpc.sw.ru>
 <20130719165037.GA18358@tucsk.piliscsaba.szeredi.hu>
 <51FBD2DF.50506@parallels.com>
 <CAJfpegtr4+vv_ZzuM7EE7MkHPqNi4brQamg4ZOWb2Me+iG87JQ@mail.gmail.com>
Subject: Re: [PATCH 10/16] fuse: Implement writepages callback
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="520123c0_507ed7ab_13e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: James Bottomley <jbottomley@parallels.com>, devel <devel@openvz.org>, Kirill Korotaev <dev@parallels.com>, Brian Foster <bfoster@redhat.com>, linux-mm <linux-mm@kvack.org>, Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, fuse-devel <fuse-devel@lists.sourceforge.net>, riel <riel@redhat.com>, Pavel Emelianov <xemul@parallels.com>, Al Viro <viro@zeniv.linux.org.uk>, Maxim Patlasov <mpatlasov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, fengguang wu <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>

--520123c0_507ed7ab_13e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable



Ok

On =46ri, Aug 2, 2013 at 5:40 PM, Maxim Patlasov <mpatlasov=40parallels.c=
om> wrote:

> 07/19/2013 08:50 PM, Miklos Szeredi =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

>

>> On Sat, Jun 29, 2013 at 09:45:29PM +0400, Maxim Patlasov wrote:

>>>

>>> =46rom: Pavel Emelyanov <xemul=40openvz.org>

>>>

>>> The .writepages one is required to make each writeback request carry =
more

>>> than

>>> one page on it. The patch enables optimized behaviour unconditionally=
,

>>> i.e. mmap-ed writes will benefit from the patch even if

>>> fc->writeback=5Fcache=3D0.

>>

>> I rewrote this a bit, so we won't have to do the thing in two passes,
=

>> which

>> makes it simpler and more robust.  Waiting for page writeback here is
=

>> wrong

>> anyway, see comment above fuse=5Fpage=5Fmkwrite().  BTW we had a race =
there

>> because

>> fuse=5Fpage=5Fmkwrite() didn't take the page lock.  I've also fixed th=
at up

>> and

>> pushed a series containing these patches up to implementing ->writepag=
es()

>> to

>>

>>    git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git

>> writepages

>>

>> Passed some trivial testing but more is needed.

>

>

> Thanks a lot for efforts. The approach you implemented looks promising,=
 but

> it introduces the following assumption: a page cannot become dirty befo=
re we

> have a chance to wait on fuse writeback holding the page locked. This i=
s

> already true for mmap-ed writes (due to your fixes) and it seems doable=
 for

> cached writes as well (like we do in fuse=5Fperform=5Fwrite). But the a=
ssumption

> seems to be broken in case of direct read from local fs (e.g. ext4) to =
a

> memory region mmap-ed to a file on fuse fs. See how dio=5Fbio=5Fsubmit(=
) marks

> pages dirty by bio=5Fset=5Fpages=5Fdirty(). I can't see any solution fo=
r this

> use-case. Do you=3F



Hmm.  Direct IO on an mmaped file will do get=5Fuser=5Fpages() which will=


do the necessary page fault magic and ->page=5Fmkwrite() will be called.
=

At least A=46AICS.



The page cannot become dirty through a memory mapping without first

switching the pte from read-only to read-write first.  Page accounting

logic relies on this too.  The other way the page can become dirty is

through write(2) on the fs.  But we do get notified about that too.



Thanks,

Miklos

--

To unsubscribe from this list: send the line =22unsubscribe linux-kernel=22=
 in

the body of a message to majordomo=40vger.kernel.org

More majordomo info at  http://vger.kernel.org/majordomo-info.html

Please read the =46AQ at  http://www.tux.org/lkml/


--520123c0_507ed7ab_13e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><br><div id=3D=22boxer-meta=22></div>Ok<span id=3D=22draft-break=22><=
/span><div><div>On Tue, Aug 06, 2013 at 11:25 AM, Miklos Szeredi <miklos=40=
szeredi.hu> wrote:<br><blockquote type=3D=22cite=22><div>On =46ri, Aug 2,=
 2013 at 5:40 PM, Maxim Patlasov <mpatlasov=40parallels.com> wrote:<br>&g=
t; 07/19/2013 08:50 PM, Miklos Szeredi =D0=BF=D0=B8=D1=88=D0=B5=D1=82:<br=
>&gt;<br>&gt;&gt; On Sat, Jun 29, 2013 at 09:45:29PM +0400, Maxim Patlaso=
v wrote:<br>&gt;&gt;&gt;<br>&gt;&gt;&gt; =46rom: Pavel Emelyanov <xemul=40=
openvz.org><br>&gt;&gt;&gt;<br>&gt;&gt;&gt; The .writepages one is requir=
ed to make each writeback request carry more<br>&gt;&gt;&gt; than<br>&gt;=
&gt;&gt; one page on it. The patch enables optimized behaviour unconditio=
nally,<br>&gt;&gt;&gt; i.e. mmap-ed writes will benefit from the patch ev=
en if<br>&gt;&gt;&gt; fc-&gt;writeback=5Fcache=3D0.<br>&gt;&gt;<br>&gt;&g=
t; I rewrote this a bit, so we won't have to do the thing in two passes,<=
br>&gt;&gt; which<br>&gt;&gt; makes it simpler and more robust.  Waiting =
for page writeback here is<br>&gt;&gt; wrong<br>&gt;&gt; anyway, see comm=
ent above fuse=5Fpage=5Fmkwrite().  BTW we had a race there<br>&gt;&gt; b=
ecause<br>&gt;&gt; fuse=5Fpage=5Fmkwrite() didn't take the page lock.  I'=
ve also fixed that up<br>&gt;&gt; and<br>&gt;&gt; pushed a series contain=
ing these patches up to implementing -&gt;writepages()<br>&gt;&gt; to<br>=
&gt;&gt;<br>&gt;&gt;    git://git.kernel.org/pub/scm/linux/kernel/git/msz=
eredi/fuse.git<br>&gt;&gt; writepages<br>&gt;&gt;<br>&gt;&gt; Passed some=
 trivial testing but more is needed.<br>&gt;<br>&gt;<br>&gt; Thanks a lot=
 for efforts. The approach you implemented looks promising, but<br>&gt; i=
t introduces the following assumption: a page cannot become dirty before =
we<br>&gt; have a chance to wait on fuse writeback holding the page locke=
d. This is<br>&gt; already true for mmap-ed writes (due to your fixes) an=
d it seems doable for<br>&gt; cached writes as well (like we do in fuse=5F=
perform=5Fwrite). But the assumption<br>&gt; seems to be broken in case o=
f direct read from local fs (e.g. ext4) to a<br>&gt; memory region mmap-e=
d to a file on fuse fs. See how dio=5Fbio=5Fsubmit() marks<br>&gt; pages =
dirty by bio=5Fset=5Fpages=5Fdirty(). I can't see any solution for this<b=
r>&gt; use-case. Do you=3F<br><br>Hmm.  Direct IO on an mmaped file will =
do get=5Fuser=5Fpages() which will<br>do the necessary page fault magic a=
nd -&gt;page=5Fmkwrite() will be called.<br>At least A=46AICS.<br><br>The=
 page cannot become dirty through a memory mapping without first<br>switc=
hing the pte from read-only to read-write first.  Page accounting<br>logi=
c relies on this too.  The other way the page can become dirty is<br>thro=
ugh write(2) on the fs.  But we do get notified about that too.<br><br>Th=
anks,<br>Miklos<br>--<br>To unsubscribe from this list: send the line =22=
unsubscribe linux-kernel=22 in<br>the body of a message to majordomo=40vg=
er.kernel.org<br>More majordomo info at  http://vger.kernel.org/majordomo=
-info.html<br>Please read the =46AQ at  http://www.tux.org/lkml/<br></xem=
ul=40openvz.org></mpatlasov=40parallels.com></div></blockquote></miklos=40=
szeredi.hu></div></div>
--520123c0_507ed7ab_13e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
