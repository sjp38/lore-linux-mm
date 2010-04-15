Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 50E426B01F5
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 07:49:19 -0400 (EDT)
Received: by gwb15 with SMTP id 15so683616gwb.14
        for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:49:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC6FBC8.9090204@kernel.org>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <4BC65237.5080408@kernel.org>
	 <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
	 <4BC6BE78.1030503@kernel.org>
	 <h2w28c262361004150100ne936d943u28f76c0f171d3db8@mail.gmail.com>
	 <4BC6CB30.7030308@kernel.org>
	 <l2u28c262361004150240q8a873b6axb73eaa32fd6e65e6@mail.gmail.com>
	 <4BC6E581.1000604@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
	 <4BC6FBC8.9090204@kernel.org>
Date: Thu, 15 Apr 2010 20:49:17 +0900
Message-ID: <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 15, 2010 at 8:43 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On 04/15/2010 07:21 PM, Minchan Kim wrote:
>> kill alloc_pages_exact_node?
>> Sorry but I can't understand your point.
>> I don't want to kill user of alloc_pages_exact_node.
>> That's opposite.
>> I want to kill user of alloc_pages_node and change it with
>> alloc_pages_any_node or alloc_pages_exact_node. :)
>
> I see, so...
>
> =C2=A0alloc_pages() =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-> alloc_pages_any_=
node()
> =C2=A0alloc_pages_node() =C2=A0 =C2=A0 -> alloc_pages_exact_node()
>
> right? =C2=A0It just seems strange to me and different from usual naming
> convention - ie. something which doesn't care about nodes usually
> doesn't carry _node postfix. =C2=A0Anyways, no big deal, those names just
> felt a bit strange to me.

I don't want to remove alloc_pages for UMA system.
#define alloc_pages alloc_page_sexact_node

What I want to remove is just alloc_pages_node. :)
Sorry for confusing you.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
