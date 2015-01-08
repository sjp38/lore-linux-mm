Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 045066B006E
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 11:32:44 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id z11so3780513lbi.10
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 08:32:42 -0800 (PST)
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com. [209.85.217.169])
        by mx.google.com with ESMTPS id vp9si9098988lbb.134.2015.01.08.08.32.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 08:32:41 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so3790197lbv.0
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 08:32:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150106004714.6d63023c.akpm@linux-foundation.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<20141210140347.GA23252@infradead.org>
	<20141210141211.GD2220@wil.cx>
	<20150105184143.GA665@infradead.org>
	<20150106004714.6d63023c.akpm@linux-foundation.org>
Date: Thu, 8 Jan 2015 11:27:09 -0500
Message-ID: <CANP1eJEFSBViZSagTh-_kAf_--xUOHf50xbLeRMzq6YcK5Vcyg@mail.gmail.com>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
From: Milosz Tanski <milosz@adfin.com>
Content-Type: multipart/alternative; boundary=089e014940aefa0366050c26827e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

--089e014940aefa0366050c26827e
Content-Type: text/plain; charset=UTF-8

On Tue, Jan 6, 2015 at 3:47 AM, Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Mon, 5 Jan 2015 10:41:43 -0800 Christoph Hellwig <hch@infradead.org>
> wrote:
>
> > On Wed, Dec 10, 2014 at 09:12:11AM -0500, Matthew Wilcox wrote:
> > > On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
> > > > What is the status of this patch set?
> > >
> > > I have no outstanding bug reports against it.  Linus told me that he
> > > wants to see it come through Andrew's tree.  I have an email two weeks
> > > ago from Andrew saying that it's on his list.  I would love to see it
> > > merged since it's almost a year old at this point.
> >
> > And since then another month and aother merge window has passed.  Is
> > there any way to speed up merging big patch sets like this one?
>
> I took a look at dax last time and found it to be unreviewable due to
> lack of design description, objectives and code comments.  Hopefully
> that's been addressed - I should get back to it fairly soon as I chew
> through merge window and holiday backlog.
>
> > Another one is non-blocking read one that has real life use on one
> > of the biggest server side webapp frameworks but doesn't seem to make
> > progress, which is a bit frustrating.
>
> I took a look at pread2() as well and I have two main issues:
>
> - The patchset includes a pwrite2() syscall which has nothing to do
>   with nonblocking reads and which was poorly described and had little
>   justification for inclusion.
>
> - We've talked for years about implementing this via fincore+pread
>   and at least two fincore implementations are floating about.  Now
>   along comes pread2() which does it all in one hit.
>
>   Which approach is best?  I expect fincore+pread is simpler, more
>   flexible and more maintainable.  But pread2() will have lower CPU
>   consumption and lower average-case latency.
>
>   But how *much* better is pread2()?  I expect the difference will be
>   minor because these operations are associated with a great big
>   cache-stomping memcpy.  If the pread2() advantage is "insignificant
>   for real world workloads" then perhaps it isn't the best way to go.
>
>   I just don't know, and diligence requires that we answer the
>   question.  But all I've seen in response to these questions is
>   handwaving.  It would be a shame to make a mistake because nobody
>   found the time to perform the investigation.
>
> Also, integration of pread2() into xfstests is (or was) happening and
> the results of that aren't yet known.
>

Andrew I  got busier with my other job related things between the
Thanksgiving & Christmas then anticipated. However, I have updated and
taken apart the patchset into two pieces (preadv2 and pwritev2). That
should make evaluating the two separately easier. With the help of Volker I
hacked up preadv2 support into samba and I hopefully have some numbers from
it soon. Finally, I'm putting together a test case for the typical webapp
middle-tier service (epoll + threadpool for diskio).

Haven't stopped, just progressing on that slower due to external factors.

-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--089e014940aefa0366050c26827e
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Tue, Jan 6, 2015 at 3:47 AM, Andrew Morton <span dir=3D"ltr">&lt;<a =
href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foun=
dation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">On Mon, =
5 Jan 2015 10:41:43 -0800 Christoph Hellwig &lt;<a href=3D"mailto:hch@infra=
dead.org" target=3D"_blank">hch@infradead.org</a>&gt; wrote:<br>
<br>
&gt; On Wed, Dec 10, 2014 at 09:12:11AM -0500, Matthew Wilcox wrote:<br>
&gt; &gt; On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote=
:<br>
&gt; &gt; &gt; What is the status of this patch set?<br>
&gt; &gt;<br>
&gt; &gt; I have no outstanding bug reports against it.=C2=A0 Linus told me=
 that he<br>
&gt; &gt; wants to see it come through Andrew&#39;s tree.=C2=A0 I have an e=
mail two weeks<br>
&gt; &gt; ago from Andrew saying that it&#39;s on his list.=C2=A0 I would l=
ove to see it<br>
&gt; &gt; merged since it&#39;s almost a year old at this point.<br>
&gt;<br>
&gt; And since then another month and aother merge window has passed.=C2=A0=
 Is<br>
&gt; there any way to speed up merging big patch sets like this one?<br>
<br>
I took a look at dax last time and found it to be unreviewable due to<br>
lack of design description, objectives and code comments.=C2=A0 Hopefully<b=
r>
that&#39;s been addressed - I should get back to it fairly soon as I chew<b=
r>
through merge window and holiday backlog.<br>
<br>
&gt; Another one is non-blocking read one that has real life use on one<br>
&gt; of the biggest server side webapp frameworks but doesn&#39;t seem to m=
ake<br>
&gt; progress, which is a bit frustrating.<br>
<br>
I took a look at pread2() as well and I have two main issues:<br>
<br>
- The patchset includes a pwrite2() syscall which has nothing to do<br>
=C2=A0 with nonblocking reads and which was poorly described and had little=
<br>
=C2=A0 justification for inclusion.<br>
<br>
- We&#39;ve talked for years about implementing this via fincore+pread<br>
=C2=A0 and at least two fincore implementations are floating about.=C2=A0 N=
ow<br>
=C2=A0 along comes pread2() which does it all in one hit.<br>
<br>
=C2=A0 Which approach is best?=C2=A0 I expect fincore+pread is simpler, mor=
e<br>
=C2=A0 flexible and more maintainable.=C2=A0 But pread2() will have lower C=
PU<br>
=C2=A0 consumption and lower average-case latency.<br>
<br>
=C2=A0 But how *much* better is pread2()?=C2=A0 I expect the difference wil=
l be<br>
=C2=A0 minor because these operations are associated with a great big<br>
=C2=A0 cache-stomping memcpy.=C2=A0 If the pread2() advantage is &quot;insi=
gnificant<br>
=C2=A0 for real world workloads&quot; then perhaps it isn&#39;t the best wa=
y to go.<br>
<br>
=C2=A0 I just don&#39;t know, and diligence requires that we answer the<br>
=C2=A0 question.=C2=A0 But all I&#39;ve seen in response to these questions=
 is<br>
=C2=A0 handwaving.=C2=A0 It would be a shame to make a mistake because nobo=
dy<br>
=C2=A0 found the time to perform the investigation.<br>
<br>
Also, integration of pread2() into xfstests is (or was) happening and<br>
the results of that aren&#39;t yet known.<br></blockquote><div><br></div><d=
iv>Andrew I =C2=A0got busier with my other job related things between the T=
hanksgiving &amp; Christmas then anticipated. However, I have updated and t=
aken apart the patchset into two pieces (preadv2 and pwritev2). That should=
 make evaluating the two separately easier. With the help of Volker I hacke=
d up preadv2 support into samba and I hopefully have some numbers from it s=
oon. Finally, I&#39;m putting together a test case for the typical webapp m=
iddle-tier service (epoll + threadpool for diskio).</div><div><br></div><di=
v>Haven&#39;t stopped, just progressing on that slower due to external fact=
ors.</div></div><div><br></div>-- <br><div><div dir=3D"ltr">Milosz Tanski<b=
r>CTO<br>16 East 34th Street, 15th floor<br>New York, NY 10016<br><br>p: <a=
 href=3D"tel:646-253-9055" value=3D"+16462539055" target=3D"_blank">646-253=
-9055</a><br>e: <a href=3D"mailto:milosz@adfin.com" target=3D"_blank">milos=
z@adfin.com</a><br></div></div>
</div></div>

--089e014940aefa0366050c26827e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
