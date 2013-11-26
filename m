Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 45A776B0035
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 01:47:05 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id c11so4151823lbj.9
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 22:47:04 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a4si14491728laf.173.2013.11.25.22.47.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 22:47:03 -0800 (PST)
Message-ID: <529443E4.7080602@parallels.com>
Date: Tue, 26 Nov 2013 10:47:00 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 00/15] kmemcg shrinkers
References: <cover.1385377616.git.vdavydov@parallels.com> <20131125174135.GE22729@cmpxchg.org>
In-Reply-To: <20131125174135.GE22729@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, glommer@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org

Hi,

Thank you for the review. I agree with all your comments and I'll resend 
the fixed version soon.

If anyone still has something to say about the patchset, I'd be glad to 
hear from them.

On 11/25/2013 09:41 PM, Johannes Weiner wrote:
> I ran out of steam reviewing these because there were too many things
> that should be changed in the first couple patches.
>
> I realize this is frustrating to see these type of complaints in v11
> of a patch series, but the review bandwidth was simply exceeded back
> when Glauber submitted this along with the kmem accounting patches.  A
> lot of the kmemcg commits themselves don't even have review tags or
> acks, but it all got merged anyway, and the author has moved on to
> different projects...
>
> Too much stuff slips past the only two people that have more than one
> usecase on their agenda and are willing to maintain this code base -
> which is in desparate need of rework and pushback against even more
> drive-by feature dumps.  I have repeatedly asked to split the memcg
> tree out of the memory tree to better deal with the vastly different
> developmental stages of memcg and the rest of the mm code, to no
> avail.  So I don't know what to do anymore, but this is not working.
>
> Thoughts?

That's a pity, because w/o this patchset kmemcg is in fact useless. 
Perhaps, it's worth trying to split it? (not sure if it'll help much 
though since first 11 patches are rather essential :-( )

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
