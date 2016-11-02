Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCAD6B02AA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 06:02:35 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id b81so2210629lfe.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 03:02:35 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 89si763347lfq.363.2016.11.02.03.02.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 03:02:33 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id o20so661676lfg.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 03:02:32 -0700 (PDT)
Date: Wed, 2 Nov 2016 12:55:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 01/20] mm: Change type of vmf->virtual_address
Message-ID: <20161102095558.GA20724@node.shutemov.name>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <1478039794-20253-2-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478039794-20253-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Nov 01, 2016 at 11:36:07PM +0100, Jan Kara wrote:
> Every single user of vmf->virtual_address typed that entry to unsigned
> long before doing anything with it. So just change the type of that
> entry to unsigned long immediately.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
