Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 775C16B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 21:10:28 -0500 (EST)
Received: by mail-vc0-f170.google.com with SMTP id hq12so2686916vcb.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 18:10:28 -0800 (PST)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com. [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id ea6si1813584vdb.14.2015.02.11.18.10.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 18:10:27 -0800 (PST)
Received: by mail-vc0-f176.google.com with SMTP id la4so2641156vcb.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 18:10:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211203359.GF21356@htj.duckdns.org>
References: <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com> <20150205131514.GD25736@htj.dyndns.org>
 <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com> <20150205222522.GA10580@htj.dyndns.org>
 <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com> <20150206141746.GB10580@htj.dyndns.org>
 <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
 <20150207143839.GA9926@htj.dyndns.org> <20150211021906.GA21356@htj.duckdns.org>
 <CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com> <20150211203359.GF21356@htj.duckdns.org>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 11 Feb 2015 18:10:06 -0800
Message-ID: <CAHH2K0agT1X9vZn56O9NFOEyEW65Tgnsrb9S4X6Dn2dtMi-iWg@mail.gmail.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

On Wed, Feb 11, 2015 at 12:33 PM, Tejun Heo <tj@kernel.org> wrote:
[...]
>> page count to throttle based on blkcg's bandwidth.  Note: memcg
>> doesn't yet have dirty page counts, but several of us have made
>> attempts at adding the counters.  And it shouldn't be hard to get them
>> merged.
>
> Can you please post those?

Will do.  Rebasing and testing needed, so it won't be today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
