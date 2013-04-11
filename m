Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 70CFF6B0038
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:11:42 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <5166CEDD.9050301@oracle.com>
References: <51559150.3040407@oracle.com>
 <20130410080202.GB21292@blaptop>
 <5166CEDD.9050301@oracle.com>
Subject: Re: mm: BUG in do_huge_pmd_wp_page
Content-Transfer-Encoding: 7bit
Message-Id: <20130411151323.89D40E0085@blue.fi.intel.com>
Date: Thu, 11 Apr 2013 18:13:23 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Sasha Levin wrote:
> On 04/10/2013 04:02 AM, Minchan Kim wrote:
> > I don't know this issue was already resolved. If so, my reply become a just
> > question to Kirill regardless of this BUG.
> 
> The issue is still reproducible with today's -next.

Could you share your kernel config and configuration of your virtual machine?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
