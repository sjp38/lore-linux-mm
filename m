Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 14D576B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:31:34 -0400 (EDT)
Received: by ywh26 with SMTP id 26so410004ywh.12
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 18:31:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC65237.5080408@kernel.org>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com>
	 <20100413154820.GC25756@csn.ul.ie> <4BC65237.5080408@kernel.org>
Date: Thu, 15 Apr 2010 10:31:23 +0900
Message-ID: <v2j28c262361004141831h8f2110d5pa7a1e3063438cbf8@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Tejun.

On Thu, Apr 15, 2010 at 8:39 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On 04/14/2010 12:48 AM, Mel Gorman wrote:
>> and the mapping table on x86 at least is based on possible CPUs in
>> init_cpu_to_node() leaves the mapping as 0 if the APIC is bad or the num=
a
>> node is reported in apicid_to_node as -1. It would appear on power that
>> the node will be 0 for possible CPUs as well.
>>
>> Hence, I believe this to be safe but a confirmation from Tejun would be
>> nice. I would continue digging but this looks like an initialisation pat=
h
>> so I'll move on to the next patch rather than spending more time.
>
> This being a pretty cold path, I don't really see much benefit in
> converting it to alloc_pages_node_exact(). =C2=A0It ain't gonna make any
> difference. =C2=A0I'd rather stay with the safer / boring one unless
> there's a pressing reason to convert.

Actually, It's to weed out not-good API usage as well as some performance g=
ain.
But I don't think to need it strongly.
Okay. Please keep in mind about this and correct it if you confirms it
in future. :)

>
> Thanks.
>
> --
> tejun
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
