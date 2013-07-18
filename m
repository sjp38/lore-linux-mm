Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id CA58A6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 16:29:30 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc8so3579154pbc.18
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 13:29:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1306271340240.17334@chino.kir.corp.google.com>
References: <51BB1802.8050108@yandex-team.ru>
	<0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com>
	<alpine.DEB.2.02.1306141322490.17237@chino.kir.corp.google.com>
	<51BF024F.2080609@yandex-team.ru>
	<20130617142715.GB8853@dhcp22.suse.cz>
	<51CBFC95.9070002@yandex-team.ru>
	<alpine.DEB.2.02.1306271340240.17334@chino.kir.corp.google.com>
Date: Thu, 18 Jul 2013 13:29:29 -0700
Message-ID: <CACKvgLF7TKAJ1CFg=9vtk0Azga0mm02devKFbh2YGLCap2NcRA@mail.gmail.com>
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
From: Vinson Lee <vlee@freedesktop.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <klamm@yandex-team.ru>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@gentwo.org>, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, li@jasper.es

On Thu, Jun 27, 2013 at 1:41 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 27 Jun 2013, Roman Gushchin wrote:
>
>> > They certainly aren't enough, the kernel you're running suffers from a
>> > couple different memory compaction issues that were fixed in 3.7.  I
>> > couldn't sympathize with your situation more, I faced the same issue
>> > because of thp and not slub (we use slab).
>> >
>> > > I'll try to reproduce the issue on raw 3.9.
>> > >
>>
>> I can't reproduce the issue on 3.9.
>> It seems that compaction fixes in 3.7 solve the problem.
>>
>
> Yeah, we had significant problems with memory compaction in 3.3 and 3.4
> kernels, so if you need to run with such a kernel you'll want to backport
> the listed commits.  I'm not sure we could get such invasive changes into
> a stable release, unfortunately.

Hi.

Can the diff with the backport of the listed patches be posted? The
patches don't easily apply to 3.4.

I think I'm seeing memory compaction issues as well with Linux kernel
3.4 and would welcome any help. I'm planning to try the backporting
approach to see if it improves things on my side.

Cheers,
Vinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
