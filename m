Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 96F546B0069
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 02:49:39 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x13so537335wgg.30
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 23:49:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si5145637wiy.51.2014.10.20.23.49.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 23:49:37 -0700 (PDT)
Date: Tue, 21 Oct 2014 08:49:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] memcg: remove activate_kmem_mutex
Message-ID: <20141021064935.GA9415@dhcp22.suse.cz>
References: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
 <20141020185306.GB505@dhcp22.suse.cz>
 <20141021063119.GM16496@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141021063119.GM16496@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 21-10-14 10:31:19, Vladimir Davydov wrote:
> On Mon, Oct 20, 2014 at 08:53:06PM +0200, Michal Hocko wrote:
> > On Mon 20-10-14 19:11:29, Vladimir Davydov wrote:
> > > The activate_kmem_mutex is used to serialize memcg.kmem.limit updates,
> > > but we already serialize them with memcg_limit_mutex so let's remove the
> > > former.
> > > 
> > > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > 
> > Is this the case since bd67314586a3 (memcg, slab: simplify
> > synchronization scheme)?
> 
> No, it's since Johannes' lockless page counters patch where we have the
> memcg_limit_mutex introduced to synchronize concurrent limit updates (mm
> commit dc1815408849 "mm: memcontrol: lockless page counters").

Ahh, ok. Thanks for the clarification.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
