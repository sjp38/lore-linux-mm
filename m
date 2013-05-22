Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 771B16B00A0
	for <linux-mm@kvack.org>; Wed, 22 May 2013 07:03:39 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BBC19.7020509@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-3-git-send-email-kirill.shutemov@linux.intel.com>
 <519BBC19.7020509@sr71.net>
Subject: Re: [PATCHv4 02/39] block: implement add_bdi_stat()
Content-Transfer-Encoding: 7bit
Message-Id: <20130522110603.4B729E0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 14:06:03 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:22 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > We're going to add/remove a number of page cache entries at once. This
> > patch implements add_bdi_stat() which adjusts bdi stats by arbitrary
> > amount. It's required for batched page cache manipulations.
> 
> Add, but no dec?

'sub', I guess, not 'dec'. For that we use add_bdi_stat(m, item, -nr).
It's consistent with __add_bdi_stat() usage.

> I'd also move this closer to where it gets used in the series.

Okay.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
