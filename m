Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 014AA6B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 03:01:17 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 17so3541421wma.1
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 00:01:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si10610656wmc.74.2018.01.31.00.01.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 00:01:15 -0800 (PST)
Date: Wed, 31 Jan 2018 09:01:14 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Lock mmap_sem when calling migrate_pages() in
 do_move_pages_to_node()
Message-ID: <20180131080114.GM21609@dhcp22.suse.cz>
References: <20180130030011.4310-1-zi.yan@sent.com>
 <20180130081415.GO21609@dhcp22.suse.cz>
 <5A7094DA.4000804@cs.rutgers.edu>
 <20180130161025.GH21609@dhcp22.suse.cz>
 <F3D5C6AC-78B6-4443-9BE1-575831F238E2@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F3D5C6AC-78B6-4443-9BE1-575831F238E2@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Tue 30-01-18 14:12:28, Zi Yan wrote:
> On 30 Jan 2018, at 11:10, Michal Hocko wrote:
[...]
> I think the question is whether we need to hold mmap_sem for
> migrate_pages(). Hugh also agrees it is not necessary on a separate
> email. But it is held in the original code.

I would be really surprised if we really needed the lock. If we do,
however, then we really need a very good explanation why. The code used
to do so is not a valid reason.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
