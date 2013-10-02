Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1975B6B0036
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 12:25:23 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so1241281pab.25
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 09:25:22 -0700 (PDT)
Date: Wed, 2 Oct 2013 09:25:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 16/26] mm: Provide get_user_pages_unlocked()
Message-ID: <20131002162519.GA9886@infradead.org>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-17-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1380724087-13927-17-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Oct 02, 2013 at 04:27:57PM +0200, Jan Kara wrote:
> Provide a wrapper for get_user_pages() which takes care of acquiring and
> releasing mmap_sem. Using this function reduces amount of places in
> which we deal with mmap_sem.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Seem like this should be the default one and the one without the locked
should be __unlocked.  Maybe a grand rename is in order?


get_user_pages_fast	-> get_user_pages
get_user_pages_unlocked	-> __get_user_pages
get_user_pages_unlocked	-> __get_user_pages_locked

steering people to the most sensible ones by default?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
