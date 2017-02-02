Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F58E6B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 08:08:29 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so3956966wjb.5
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 05:08:29 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id f4si17833767wmf.139.2017.02.02.05.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 05:08:27 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id c85so4029690wmi.1
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 05:08:27 -0800 (PST)
Date: Thu, 2 Feb 2017 16:08:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/4] mm: Fix sparse, use plain integer as NULL pointer
Message-ID: <20170202130825.GA32180@node>
References: <1485992240-10986-1-git-send-email-me@tobin.cc>
 <1485992240-10986-2-git-send-email-me@tobin.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485992240-10986-2-git-send-email-me@tobin.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>

On Thu, Feb 02, 2017 at 10:37:17AM +1100, Tobin C. Harding wrote:
> From: Tobin C Harding <me@tobin.cc>
> 
> Patch fixes sparse warning: Using plain integer as NULL pointer. Replaces
> assignment of 0 to pointer with NULL assignment.
> 
> Signed-off-by: Tobin C Harding <me@tobin.cc>

I wrote this part when ARC had pgtable_t defined as 'unsigned long', so
NULL wasn't an option, but 0 was as it's valid pointer according to spec.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
