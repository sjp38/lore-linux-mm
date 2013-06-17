Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E82FB6B0031
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:44:56 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bi5so3282672pad.32
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 14:44:56 -0700 (PDT)
Date: Mon, 17 Jun 2013 14:44:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
In-Reply-To: <51BF230E.8050904@yandex-team.ru>
Message-ID: <alpine.DEB.2.02.1306171441510.20631@chino.kir.corp.google.com>
References: <51BB1802.8050108@yandex-team.ru> <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com> <alpine.DEB.2.02.1306141322490.17237@chino.kir.corp.google.com> <51BF024F.2080609@yandex-team.ru> <20130617142715.GB8853@dhcp22.suse.cz>
 <51BF230E.8050904@yandex-team.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@gentwo.org>, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Jun 2013, Roman Gushchin wrote:

> > FWIW, there were some compaction locking related patches merged
> > around 3.7. See 2a1402aa044b55c2d30ab0ed9405693ef06fb07c and follow ups.
> 
> Thanks, Michal.
> I've already tried to backport some of those patches, but it didn't help
> (may be it wasn't enough).

They certainly aren't enough, the kernel you're running suffers from a 
couple different memory compaction issues that were fixed in 3.7.  I 
couldn't sympathize with your situation more, I faced the same issue 
because of thp and not slub (we use slab).

> I'll try to reproduce the issue on raw 3.9.
> 

Thanks.  If you need to go back to 3.4, try using these, they 
significantly helped our issues:

bb13ffeb9f6bfeb301443994dfbf29f91117dfb3
627260595ca6abcb16d68a3732bac6b547e112d6
c89511ab2f8fe2b47585e60da8af7fd213ec877e
62997027ca5b3d4618198ed8b1aba40b61b1137b
a9aacbccf3145355190d87f0df1731fb84fdd8c8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
