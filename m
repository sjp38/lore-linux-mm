Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 219D16B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 21:38:14 -0500 (EST)
Received: by pzk8 with SMTP id 8so368693pzk.22
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 18:38:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B74524D.8080804@nortel.com>
References: <4B71927D.6030607@nortel.com>
	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>
	 <4B72E74C.9040001@nortel.com>
	 <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com>
	 <4B74524D.8080804@nortel.com>
Date: Fri, 12 Feb 2010 11:38:12 +0900
Message-ID: <28c262361002111838q7db763feh851a9bea4fdd9096@mail.gmail.com>
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 12, 2010 at 3:54 AM, Chris Friesen <cfriesen@nortel.com> wrote:
> That just makes the comparison even worse...it means that there is more
> memory in active/inactive that isn't accounted for in any other category
> in /proc/meminfo.

Hmm. It's very strange. It's impossible if your kernel and drivers is norma=
l.
Could you grep sources who increases NR_ACTIVE/INACTIVE?
I doubt one of your driver does increase and miss decrease.

>> Now kernel don't account kernel memory allocations except SLAB.
>
> I don't think that's entirely accurate. =C2=A0I think cached, buffers,
> pagetables, vmallocUsed are all kernel allocations. =C2=A0Granted, they'r=
e
> generally on behalf of userspace.

Yes. I just said simple. What I means kernel doesn't account whole memory
usage. :)

> I have a modified version of that which I picked up as part of the
> kmemleak backport. =C2=A0However, it doesn't help unless I can narrow dow=
n
> *which* pages I should care about.

kmemleak doesn't support page allocator and ioremap.
Above URL patch just can tell who requests page which is using(ie, not
free) now.


> I tried using kmemleak directly, but it didn't find anything. =C2=A0I've =
also
> tried checking for inactive pages which haven't been written to in 10
> minutes, and haven't had much luck there either. =C2=A0But active/inactiv=
e
> keeps growing, and I don't know why.

If leak cause by alloc_page or __get_free_pages, kmemleak can't find leak.

>
> Chris
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
