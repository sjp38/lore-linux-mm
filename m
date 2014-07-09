Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3596C6B0038
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 20:03:41 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id x19so2904405ier.18
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 17:03:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d14si17425574icn.44.2014.07.08.17.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 17:03:40 -0700 (PDT)
Date: Tue, 8 Jul 2014 17:02:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: update the description for vm_total_pages
Message-Id: <20140708170249.718ba725.akpm@linux-foundation.org>
In-Reply-To: <53BC8282.8080602@gmail.com>
References: <53BB8553.10508@gmail.com>
	<20140708134136.597fbd11309d1e376eeb241c@linux-foundation.org>
	<53BC8282.8080602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org

On Wed, 09 Jul 2014 07:45:06 +0800 Wang Sheng-Hui <shhuiw@gmail.com> wrote:

> >> +unsigned long vm_total_pages;
> >>
> >>  static LIST_HEAD(shrinker_list);
> >>  static DECLARE_RWSEM(shrinker_rwsem);
> > 
> > Nice patch!  It's good to document these little things as one discovers
> > them.
> > 
> > However vm_total_pages is only ever used in build_all_zonelists() and
> > could be made a local within that function.
> 
> We can see that vm_total_pages is not used in build_all_zonelist() only.
>           http://lxr.oss.org.cn/search?string=vm_total_pages

Look more closely ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
