Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55CF96B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 10:34:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so43061480wme.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:34:17 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id j123si8998656wmb.118.2016.04.25.07.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 07:34:16 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id u206so130732299wme.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 07:34:16 -0700 (PDT)
Date: Mon, 25 Apr 2016 16:34:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] mainline and mmotm compaction fixes
Message-ID: <20160425143413.GJ23933@dhcp22.suse.cz>
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On Mon 25-04-16 15:34:26, Vlastimil Babka wrote:
[...]
> > 1. Fix crash in release_pages() from compact_zone() from kcompactd_do_work():
> >     kcompactd needs to INIT_LIST_HEAD on the new freepages_held list.
> 
> This one should be addressed by dropping the following from mmotm from now:
> 
> mm-compaction-direct-freepage-allocation-for-async-direct-compaction.patch

I can confirm that this has healed
[  481.380167] BUG: unable to handle kernel NULL pointer dereference at           (null)
[  481.382594] IP: [<ffffffff81134dc7>] release_freepages+0x1c/0x7d

I was hitting today during testing something unrelated.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
