Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E45576B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 02:53:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d128so3958145wmf.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 23:53:35 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id tp11si8608850wjb.241.2016.10.11.23.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 23:53:34 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id b80so886264wme.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 23:53:34 -0700 (PDT)
Date: Wed, 12 Oct 2016 08:53:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when
 allocate a odd alignment area
Message-ID: <20161012065332.GA9504@dhcp22.suse.cz>
References: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
 <20161011172228.GA30403@dhcp22.suse.cz>
 <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7649b844-cfe6-abce-148e-1e2236e7d443@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, cl@linux.com

On Wed 12-10-16 08:28:17, zijun_hu wrote:
> On 2016/10/12 1:22, Michal Hocko wrote:
> > On Tue 11-10-16 21:24:50, zijun_hu wrote:
> >> From: zijun_hu <zijun_hu@htc.com>
> >>
> >> the LSB of a chunk->map element is used for free/in-use flag of a area
> >> and the other bits for offset, the sufficient and necessary condition of
> >> this usage is that both size and alignment of a area must be even numbers
> >> however, pcpu_alloc() doesn't force its @align parameter a even number
> >> explicitly, so a odd @align maybe causes a series of errors, see below
> >> example for concrete descriptions.
> > 
> > Is or was there any user who would use a different than even (or power of 2)
> > alighment? If not is this really worth handling?
> > 
> 
> it seems only a power of 2 alignment except 1 can make sure it work very well,
> that is a strict limit, maybe this more strict limit should be checked

I fail to see how any other alignment would actually make any sense
what so ever. Look, I am not a maintainer of this code but adding a new
code to catch something that doesn't make any sense sounds dubious at
best to me.

I could understand this patch if you see a problem and want to prevent
it from repeating bug doing these kind of changes just in case sounds
like a bad idea.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
