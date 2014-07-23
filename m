Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 964A16B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:23:55 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so996204wes.7
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:23:54 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.201])
        by mx.google.com with ESMTP id be4si4152902wjc.162.2014.07.23.04.23.49
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 04:23:50 -0700 (PDT)
Date: Wed, 23 Jul 2014 14:23:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v8 02/22] Allow page fault handlers to perform the COW
Message-ID: <20140723112347.GB10317@node.dhcp.inet.fi>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b765e16e66c9422c896294a11fe624ecb7e44384.1406058387.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b765e16e66c9422c896294a11fe624ecb7e44384.1406058387.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Tue, Jul 22, 2014 at 03:47:50PM -0400, Matthew Wilcox wrote:
> Currently COW of an XIP file is done by first bringing in a read-only
> mapping, then retrying the fault and copying the page.  It is much more
> efficient to tell the fault handler that a COW is being attempted (by
> passing in the pre-allocated page in the vm_fault structure), and allow
> the handler to perform the COW operation itself.
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
