Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8552B6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 21:41:59 -0400 (EDT)
Received: by oihr205 with SMTP id r205so1808767oih.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:41:59 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id m81si270008oig.113.2015.10.12.18.41.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 18:41:58 -0700 (PDT)
Received: by oiar126 with SMTP id r126so1840468oia.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 18:41:58 -0700 (PDT)
Subject: Re: [PATCH] mm: cleanup balance_dirty_pages() that leave variables
 uninitialized
References: <1444652698-28292-1-git-send-email-liaotonglang@gmail.com>
 <20151012125835.GD17050@quack.suse.cz>
From: Liao Tonglang <liaotonglang@gmail.com>
Message-ID: <561C6160.2090400@gmail.com>
Date: Tue, 13 Oct 2015 09:41:52 +0800
MIME-Version: 1.0
In-Reply-To: <20151012125835.GD17050@quack.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: tj@kernel.org, axboe@fb.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2015/10/12 20:58, Jan Kara wrote:
> What
> gcc version are you using?
It is the last line of my gcc -v command.
     gcc version 4.8.3 20140911 (Red Hat 4.8.3-9) (GCC)
And it warn like this:
mm/page-writeback.c: In function ?balance_dirty_pages.isra.26?:
mm/page-writeback.c:1537:26: warning: ?m_thresh? may be used 
uninitialized in this function [-Wmaybe-uninitialized]
    unsigned long m_dirty, m_thresh, m_bg_thresh;
                           ^
mm/page-writeback.c:1537:17: warning: ?m_dirty? may be used 
uninitialized in this function [-Wmaybe-uninitialized]
    unsigned long m_dirty, m_thresh, m_bg_thresh;
                  ^

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
