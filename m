Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 112B06B00A3
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 16:19:05 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o9RKJ2sr019063
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:19:02 -0700
Received: from qyk8 (qyk8.prod.google.com [10.241.83.136])
	by wpaz21.hot.corp.google.com with ESMTP id o9RKJ0D3003438
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:19:01 -0700
Received: by qyk8 with SMTP id 8so1113345qyk.18
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:19:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CC869F5.2070405@redhat.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
Date: Wed, 27 Oct 2010 13:19:00 -0700
Message-ID: <AANLkTim9ENR7dFvkNW_h2-Bfg6GHCbOgr6Bd=W34z7s0@mail.gmail.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016364274e5961ba604939eef24
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--0016364274e5961ba604939eef24
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Oct 27, 2010 at 11:05 AM, Rik van Riel <riel@redhat.com> wrote:

> On 10/27/2010 01:21 PM, Ying Han wrote:
>
>> kswapd's use case of hardware PTE accessed bit is to approximate page LRU.
>>  The
>> ActiveLRU demotion to InactiveLRU are not base on accessed bit, while it
>> is only
>> used to promote when a page is on inactive LRU list.  All of the state
>> transitions
>> are triggered by memory pressure and thus has weak relationship with
>> respect to
>> time.  In addition, hardware already transparently flush tlb whenever CPU
>> context
>> switch processes and given limited hardware TLB resource, the time period
>> in
>> which a page is accessed but not yet propagated to struct page is very
>> small
>> in practice. With the nature of approximation, kernel really don't need to
>> flush TLB
>> for changing PTE's access bit.  This commit removes the flush operation
>> from it.
>>
>> Signed-off-by: Ying Han<yinghan@google.com>
>> Singed-off-by: Ken Chen<kenchen@google.com>
>>
>
> The reasoning behind the patch makes sense.
>
> However, have you measured any improvements in run time with
> this patch?  The VM is already tweaked to minimize the number
> of pages that get aged, so it would be interesting to know
> where you saw issues.
>

Rik, the workload we were running are some MapReduce jobs.

--Ying

>
> --
> All rights reversed
>

--0016364274e5961ba604939eef24
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Oct 27, 2010 at 11:05 AM, Rik va=
n Riel <span dir=3D"ltr">&lt;<a href=3D"mailto:riel@redhat.com">riel@redhat=
.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On 10/27/2010 01:21 PM, Ying Han wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
kswapd&#39;s use case of hardware PTE accessed bit is to approximate page L=
RU. =A0The<br>
ActiveLRU demotion to InactiveLRU are not base on accessed bit, while it is=
 only<br>
used to promote when a page is on inactive LRU list. =A0All of the state tr=
ansitions<br>
are triggered by memory pressure and thus has weak relationship with respec=
t to<br>
time. =A0In addition, hardware already transparently flush tlb whenever CPU=
 context<br>
switch processes and given limited hardware TLB resource, the time period i=
n<br>
which a page is accessed but not yet propagated to struct page is very smal=
l<br>
in practice. With the nature of approximation, kernel really don&#39;t need=
 to flush TLB<br>
for changing PTE&#39;s access bit. =A0This commit removes the flush operati=
on from it.<br>
<br>
Signed-off-by: Ying Han&lt;<a href=3D"mailto:yinghan@google.com" target=3D"=
_blank">yinghan@google.com</a>&gt;<br>
Singed-off-by: Ken Chen&lt;<a href=3D"mailto:kenchen@google.com" target=3D"=
_blank">kenchen@google.com</a>&gt;<br>
</blockquote>
<br></div>
The reasoning behind the patch makes sense.<br>
<br>
However, have you measured any improvements in run time with<br>
this patch? =A0The VM is already tweaked to minimize the number<br>
of pages that get aged, so it would be interesting to know<br>
where you saw issues.<br></blockquote><div><br></div><div>Rik, the workload=
 we were running are some MapReduce jobs.</div><div><br></div><div>--Ying</=
div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-lef=
t:1px #ccc solid;padding-left:1ex;">
<font color=3D"#888888">
<br>
-- <br>
All rights reversed<br>
</font></blockquote></div><br>

--0016364274e5961ba604939eef24--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
