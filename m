Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8816B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:25:13 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so1021517wes.19
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:25:12 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.201])
        by mx.google.com with ESMTP id a1si4311019wje.8.2014.07.23.04.24.53
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 04:24:53 -0700 (PDT)
Date: Wed, 23 Jul 2014 14:24:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v8 03/22] axonram: Fix bug in direct_access
Message-ID: <20140723112446.GC10317@node.dhcp.inet.fi>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <eee43fe81080cb2b6eba77f84e2b48ea6bc07573.1406058387.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <eee43fe81080cb2b6eba77f84e2b48ea6bc07573.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Tue, Jul 22, 2014 at 03:47:51PM -0400, Matthew Wilcox wrote:
> The 'pfn' returned by axonram was completely bogus, and has been since
> 2008.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
