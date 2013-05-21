Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 82DAF6B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 14:37:18 -0400 (EDT)
Message-ID: <519BBEDC.1030607@sr71.net>
Date: Tue, 21 May 2013 11:37:16 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 00/39] Transparent huge page cache
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:22 PM, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> 
> It's version 4. You can also use git tree:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git
> 
> branch thp/pagecache.
> 
> If you want to check changes since v3 you can look at diff between tags
> thp/pagecache/v3 and thp/pagecache/v4-prerebase.

What's the purpose of posting these patches?  Do you want them merged?
Or are they useful as they stand, or are they just here so folks can
play with them as you improve them?

> The goal of the project is preparing kernel infrastructure to handle huge
> pages in page cache.
> 
> To proof that the proposed changes are functional we enable the feature
> for the most simple file system -- ramfs. ramfs is not that useful by
> itself, but it's good pilot project. It provides information on what
> performance boost we should expect on other files systems.

Do you think folks would use ramfs in practice?  Or is this just a toy?
 Could this replace some (or all) existing hugetlbfs use, for instance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
