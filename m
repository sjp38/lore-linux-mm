Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 94A476B01F5
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:33:27 -0400 (EDT)
Received: by iwn40 with SMTP id 40so502462iwn.1
        for <linux-mm@kvack.org>; Thu, 15 Apr 2010 03:33:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <20100413154820.GC25756@csn.ul.ie> <4BC65237.5080408@kernel.org>
	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
	 <4BC6BE78.1030503@kernel.org>
	 <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
	 <4BC6CB30.7030308@kernel.org>
	 <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
	 <4BC6E581.1000604@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
Date: Thu, 15 Apr 2010 19:33:28 +0900
Message-ID: <n2i28c262361004150333nf1bac78dr13acc418496e6a6b@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 7:21 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Apr 15, 2010 at 7:08 PM, Tejun Heo <tj@kernel.org> wrote:
>> Hello,
>>
>> On 04/15/2010 06:40 PM, Minchan Kim wrote:
>>>> I'm not an expert on that part of the kernel but isn't
>>>> alloc_pages_any_node() identical to alloc_pages_exact_node()? =C2=A0Al=
l
>>>
>>> alloc_pages_any_node means user allows allocated pages in any
>>> node(most likely current node) alloc_pages_exact_node means user
>>> allows allocated pages in nid node if he doesn't use __GFP_THISNODE.
>>
>> Ooh, sorry, I meant alloc_pages(). =C2=A0What would be the difference
>> between alloc_pages_any_node() and alloc_pages()?
>
> It's no different. It's same. Just naming is more explicit. :)
> I think it could be following as.
>
> #define alloc_pages alloc_pages_any_node.
> strucdt page * alloc_pages_node() {
typo. Sorry.
struct page * alloc_pages_any_node {

> =C2=A0 int nid =3D numa_node_id();
> =C2=A0 ...
> =C2=A0 return page;
> }
>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
