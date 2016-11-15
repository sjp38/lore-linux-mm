Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 523546B02DF
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:44:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so10160943wme.4
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:44:08 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id c1si30395996wjn.227.2016.11.15.14.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:44:07 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id g23so199396220wme.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:44:07 -0800 (PST)
Date: Wed, 16 Nov 2016 01:44:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 15/21] mm: Move part of wp_page_reuse() into the single
 call site
Message-ID: <20161115224405.GO23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-16-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-16-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:11AM +0100, Jan Kara wrote:
> wp_page_reuse() handles write shared faults which is needed only in
> wp_page_shared(). Move the handling only into that location to make
> wp_page_reuse() simpler and avoid a strange situation when we sometimes
> pass in locked page, sometimes unlocked etc.
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
