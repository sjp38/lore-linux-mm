Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B597440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 09:41:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q126so5520226pgq.7
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 06:41:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f2si6718952plr.422.2017.11.09.06.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 06:41:27 -0800 (PST)
Date: Thu, 9 Nov 2017 06:41:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 4/4] export radix_tree_iter_tag_set
Message-ID: <20171109144125.GA23842@bombadil.infradead.org>
References: <1510167660-26196-1-git-send-email-josef@toxicpanda.com>
 <1510167660-26196-4-git-send-email-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510167660-26196-4-git-send-email-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed, Nov 08, 2017 at 02:01:00PM -0500, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> We use this in btrfs for metadata writeback.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Acked-by: Matthew Wilcox <mawilcox@microsoft.com>

In good news, this API will be more readily accessible in the XArray
and it'll be exported to modules.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
