Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id C9D716B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 17:46:34 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id i13so1657746qae.21
        for <linux-mm@kvack.org>; Sun, 04 May 2014 14:46:34 -0700 (PDT)
Received: from omr-m06.mx.aol.com (omr-m06.mx.aol.com. [64.12.143.80])
        by mx.google.com with ESMTPS id k47si2624089qgd.2.2014.05.04.14.46.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 May 2014 14:46:34 -0700 (PDT)
Date: Sun, 4 May 2014 16:46:32 -0500
From: 502304919 <boxerapp@aol.com>
Message-ID: <7B6EBC22-9E57-4702-865C-8837969E824F@aol.com>
In-Reply-To: <5366A9D9.8000100@nod.at>
References: <5366A9D9.8000100@nod.at>
Subject: Re: [3.15rc1] BUG at mm/filemap.c:202!
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="5366b538_66334873_7f3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

--5366b538_66334873_7f3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I've added this to my to-do list. On May 4, 2014 at 3:58:01 PM CDT, Richa=
rd Weinberger <richard=40nod.at> wrote:Am 04.05.2014 22:37, schrieb Hugh =
Dickins:> On Sat, 3 May 2014, Richard Weinberger wrote:>> On Thu, May 1, =
2014 at 6:20 PM, Richard Weinberger>>  wrote:>>> On Wed, Apr 16, 2014 at =
10:40 PM, Hugh Dickins  wrote:>>>>>>>> Help=21>>>>>> Using a trinity as o=
f today I'm able to trigger this bug on UML within seconds.>>> If you wan=
t me to test patch, I can help.>>>>>> I'm also observing one strange fact=
, I can trigger this on any kernel version.>>> So far I've managed UML to=
 crash on 3.0 to 3.15-rc...>>>> After digging deeper into UML's mmu and t=
lb code I've found issues and>> fixed them.>>>> But I'm still facing this=
 issue. Although triggering the BUG=5FON() is>> not so easy as before>> I=
 can trigger =22BUG: Bad rss-counter ...=22 very easily.>> Now the intere=
sting fact, with my UML mmu and flb fixes applied it>> happens only on ke=
rnels >=3D 3.14.>> If it helps I can try to bisect it.> > Thanks a lot fo=
r trying, but from other mail it looks like your> bisection got blown off=
 course ;(Yeah, looks like the issue I'm facing on UML is a completely di=
fferentstory. Although the symptoms are identical. :-(> I expect for the =
moment you'll want to concentrate on getting UML's> TLB flushing back on =
track with 3.15-rc.This is what I'm currently doing. But it might take so=
me timeas I'm a mm novice.> Once you have that sorted out, I wouldn't be =
surprised if the same> changes turn out to fix your =22Bad rss-counter=22=
s on 3.14 also.> > If not, and if you do still have time to bisect back b=
etween 3.13 and> 3.14 to find where things went wrong, it will be a bit t=
edious in that> you would probably have to apply> > 887843961c4b =22mm: f=
ix bad rss-counter if remap=5Ffile=5Fpages raced migration=22> 7e09e738af=
d2 =22mm: fix swapops.h:131 bug if remap=5Ffile=5Fpages raced migration=22=
> > at each stage, to avoid those now-known bugs which trinity became rat=
her> good at triggering. Perhaps other fixes needed, those the two I reme=
mber.> > Please don't worry if you don't have time for this, that's under=
standable.> > Or is UML so contrary that one of those commits actually br=
ings on the> problem for you=3FHehe, no. I gave it a quick try, both 8878=
43961c4b and 7e09e738afd2seem to be unrelated to the issues I see.Thanks,=
//richard--To unsubscribe from this list: send the line =22unsubscribe li=
nux-kernel=22 inthe body of a message to majordomo=40vger.kernel.orgMore =
majordomo info at http://vger.kernel.org/majordomo-info.htmlPlease read t=
he =46AQ at http://www.tux.org/lkml/     
--5366b538_66334873_7f3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<html><body><div>I've added this to my to-do list.</div><br/><br/><div><d=
iv class=3D=22quote=22>On May 4, 2014 at 3:58:01 PM CDT, Richard Weinberg=
er &lt;richard=40nod.at&gt; wrote:<br/><blockquote type=3D=22cite=22 styl=
e=3D=22border-left-style:solid;border-width:1px;margin-left:0px;padding-l=
eft:10px;=22>Am 04.05.2014 22:37, schrieb Hugh Dickins:<br />> On Sat, 3 =
May 2014, Richard Weinberger wrote:<br />>> On Thu, May 1, 2014 at 6:20 P=
M, Richard Weinberger<br />>> <richard.weinberger=40gmail.com> wrote:<br =
/>>>> On Wed, Apr 16, 2014 at 10:40 PM, Hugh Dickins <hughd=40google.com>=
 wrote:<br />>>>><br />>>>> Help=21<br />>>><br />>>> Using a trinity as =
of today I'm able to trigger this bug on UML within seconds.<br />>>> If =
you want me to test patch, I can help.<br />>>><br />>>> I'm also observi=
ng one strange fact, I can trigger this on any kernel version.<br />>>> S=
o far I've managed UML to crash on 3.0 to 3.15-rc...<br />>><br />>> Afte=
r digging deeper into UML's mmu and tlb code I've found issues and<br />>=
> fixed them.<br />>><br />>> But I'm still facing this issue. Although t=
riggering the BUG=5FON() is<br />>> not so easy as before<br />>> I can t=
rigger =22BUG: Bad rss-counter ...=22 very easily.<br />>> Now the intere=
sting fact, with my UML mmu and flb fixes applied it<br />>> happens only=
 on kernels >=3D 3.14.<br />>> If it helps I can try to bisect it.<br />>=
 <br />> Thanks a lot for trying, but from other mail it looks like your<=
br />> bisection got blown off course ;(<br /><br />Yeah, looks like the =
issue I'm facing on UML is a completely different<br />story. Although th=
e symptoms are identical. :-(<br /><br />> I expect for the moment you'll=
 want to concentrate on getting UML's<br />> TLB flushing back on track w=
ith 3.15-rc.<br /><br />This is what I'm currently doing. But it might ta=
ke some time<br />as I'm a mm novice.<br /><br />> Once you have that sor=
ted out, I wouldn't be surprised if the same<br />> changes turn out to f=
ix your =22Bad rss-counter=22s on 3.14 also.<br />> <br />> If not, and i=
f you do still have time to bisect back between 3.13 and<br />> 3.14 to f=
ind where things went wrong, it will be a bit tedious in that<br />> you =
would probably have to apply<br />> <br />> 887843961c4b =22mm: fix bad r=
ss-counter if remap=5Ffile=5Fpages raced migration=22<br />> 7e09e738afd2=
 =22mm: fix swapops.h:131 bug if remap=5Ffile=5Fpages raced migration=22<=
br />> <br />> at each stage, to avoid those now-known bugs which trinity=
 became rather<br />> good at triggering.  Perhaps other fixes needed, th=
ose the two I remember.<br />> <br />> Please don't worry if you don't ha=
ve time for this, that's understandable.<br />> <br />> Or is UML so cont=
rary that one of those commits actually brings on the<br />> problem for =
you=3F<br /><br />Hehe, no. I gave it a quick try, both 887843961c4b and =
7e09e738afd2<br />seem to be unrelated to the issues I see.<br /><br />Th=
anks,<br />//richard<br />--<br />To unsubscribe from this list: send the=
 line =22unsubscribe linux-kernel=22 in<br />the body of a message to maj=
ordomo=40vger.kernel.org<br />More majordomo info at  http://vger.kernel.=
org/majordomo-info.html<br />Please read the =46AQ at  http://www.tux.org=
/lkml/<br /></blockquote></div></div></body></html>
--5366b538_66334873_7f3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
