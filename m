Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8608C6B0031
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 09:55:03 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130617153120.6EADFE0090@blue.fi.intel.com>
References: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130617153120.6EADFE0090@blue.fi.intel.com>
Subject: [PING] Transparent huge page cache: phase 0, prep work
Content-Transfer-Encoding: 7bit
Message-Id: <20130625135746.E6506E0090@blue.fi.intel.com>
Date: Tue, 25 Jun 2013 16:57:46 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Kirill A. Shutemov wrote:
> Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > My patchset which introduces transparent huge page cache is pretty big and
> > hardly reviewable. Dave Hansen suggested to split it in few parts.
> > 
> > This is the first part: preparation work. I think it's useful without rest
> > patches.
> > 
> > There's one fix for bug in lru_add_page_tail(). I doubt it's possible to
> > trigger it on current code, but nice to have it upstream anyway.
> > Rest is cleanups.
> > 
> > Patch 8 depends on patch 7. Other patches are independent and can be
> > applied separately.
> > 
> > Please, consider applying.
> 
> Andrew, Andrea, any feedback?

Ping?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
