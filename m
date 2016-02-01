Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id E0F8F6B0253
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:10:21 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so70231920wmz.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:10:21 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id hu9si39814002wjb.54.2016.02.01.05.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 05:10:21 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id l66so9064696wml.2
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 05:10:20 -0800 (PST)
Date: Mon, 1 Feb 2016 15:10:19 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/6] dax: Use PAGE_CACHE_SIZE where appropriate
Message-ID: <20160201131019.GC29337@node.shutemov.name>
References: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
 <1454242795-18038-5-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454242795-18038-5-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun, Jan 31, 2016 at 11:19:53PM +1100, Matthew Wilcox wrote:
> We were a little sloppy about using PAGE_SIZE instead of PAGE_CACHE_SIZE.

PAGE_CACHE_SIZE is non-sense. It never had any meaning. At least in
upstream. And only leads to confusion on border between vfs and mm.

We should just drop it.

I need to find time at some point to prepare patchset...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
