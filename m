Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 925446B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:58:41 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so165602pgt.1
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:58:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si2737183pll.139.2017.09.14.10.58.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 10:58:40 -0700 (PDT)
Date: Thu, 14 Sep 2017 19:57:07 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 02/15] btrfs: Use pagevec_lookup_range_tag()
Message-ID: <20170914175707.GX29043@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20170914131819.26266-1-jack@suse.cz>
 <20170914131819.26266-3-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170914131819.26266-3-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, ceph-devel@vger.kernel.org, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>

On Thu, Sep 14, 2017 at 03:18:06PM +0200, Jan Kara wrote:
> We want only pages from given range in btree_write_cache_pages() and
> extent_write_cache_pages(). Use pagevec_lookup_range_tag() instead of
> pagevec_lookup_tag() and remove unnecessary code.
> 
> CC: linux-btrfs@vger.kernel.org
> CC: David Sterba <dsterba@suse.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Reviewed-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
