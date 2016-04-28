Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE1B16B025F
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:28:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w143so6658161wmw.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:28:14 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id v124si37826566wmd.119.2016.04.28.08.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:28:13 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id e201so81241410wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:28:13 -0700 (PDT)
Date: Thu, 28 Apr 2016 17:28:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] md: simplify free_params for kmalloc vs vmalloc fallback
Message-ID: <20160428152812.GM31489@dhcp22.suse.cz>
References: <1461849846-27209-20-git-send-email-mhocko@kernel.org>
 <1461855076-1682-1-git-send-email-mhocko@kernel.org>
 <alpine.LRH.2.02.1604281059290.14065@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1604281059290.14065@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shli@kernel.org>, dm-devel@redhat.com

On Thu 28-04-16 11:04:05, Mikulas Patocka wrote:
> Acked-by: Mikulas Patocka <mpatocka@redhat.com>

Thanks!

> BTW. we could also use kvmalloc to complement kvfree, proposed here: 
> https://www.redhat.com/archives/dm-devel/2015-July/msg00046.html

If there are sufficient users (I haven't checked other than quick git
grep on KMALLOC_MAX_SIZE and there do not seem that many) who are
sharing the same fallback strategy then why not. But I suspect that some
would rather fallback earlier and even do not attempt larger than e.g.
order-1 requests.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
