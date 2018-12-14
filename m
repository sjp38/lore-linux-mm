Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B627F8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:44:56 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c18so3090867edt.23
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:44:56 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l16si313381edv.432.2018.12.14.10.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 10:44:55 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC 4/4] mm: show number of vmalloc pages in /proc/meminfo
Date: Fri, 14 Dec 2018 18:42:50 +0000
Message-ID: <20181214184244.GA5196@castle.DHCP.thefacebook.com>
References: <20181214180720.32040-1-guro@fb.com>
 <20181214180720.32040-5-guro@fb.com>
 <20181214182904.GE10600@bombadil.infradead.org>
In-Reply-To: <20181214182904.GE10600@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <E8AD0CC77F4BD34387B5096E9F03B38D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Roman Gushchin <guroan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

On Fri, Dec 14, 2018 at 10:29:04AM -0800, Matthew Wilcox wrote:
> On Fri, Dec 14, 2018 at 10:07:20AM -0800, Roman Gushchin wrote:
> > Vmalloc() is getting more and more used these days (kernel stacks,
> > bpf and percpu allocator are new top users), and the total %
> > of memory consumed by vmalloc() can be pretty significant
> > and changes dynamically.
> >=20
> > /proc/meminfo is the best place to display this information:
> > its top goal is to show top consumers of the memory.
> >=20
> > Since the VmallocUsed field in /proc/meminfo is not in use
> > for quite a long time (it has been defined to 0 by the
> > commit a5ad88ce8c7f ("mm: get rid of 'vmalloc_info' from
> > /proc/meminfo")), let's reuse it for showing the actual
> > physical memory consumption of vmalloc().
>=20
> Do you see significant contention on nr_vmalloc_pages?  Also, if it's
> just an atomic_long_t, is it worth having an accessor for it?  And if
> it is worth having an accessor for it, then it can be static.

Not really, so I decided that per-cpu counter is an overkill
right now; but we can easily switch over once we'll notice any contention.
Will add static.

>=20
> Also, I seem to be missing 3/4.
>=20

Hm, https://lkml.org/lkml/2018/12/14/1048 ?

Thanks!
