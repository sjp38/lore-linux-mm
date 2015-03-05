Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F035F6B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:04:47 -0500 (EST)
Received: by wibhm9 with SMTP id hm9so16367096wib.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:04:47 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id jz10si13429513wjc.98.2015.03.05.08.04.44
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 08:04:44 -0800 (PST)
Date: Thu, 5 Mar 2015 18:04:26 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 00/24] THP refcounting redesign
Message-ID: <20150305160426.GA20370@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <54F85233.1010006@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F85233.1010006@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 05, 2015 at 01:55:15PM +0100, Jerome Marchand wrote:
> On 03/04/2015 05:32 PM, Kirill A. Shutemov wrote:
> > Hello everybody,
> > 
> > It's bug-fix update of my thp refcounting work.
> > 
> > The goal of patchset is to make refcounting on THP pages cheaper with
> > simpler semantics and allow the same THP compound page to be mapped with
> > PMD and PTEs. This is required to get reasonable THP-pagecache
> > implementation.
> > 
> > With the new refcounting design it's much easier to protect against
> > split_huge_page(): simple reference on a page will make you the deal.
> > It makes gup_fast() implementation simpler and doesn't require
> > special-case in futex code to handle tail THP pages.
> > 
> > It should improve THP utilization over the system since splitting THP in
> > one process doesn't necessary lead to splitting the page in all other
> > processes have the page mapped.
> > 
> [...]
> > I believe all known bugs have been fixed, but I'm sure Sasha will bring more
> > reports.
> > 
> > The patchset also available on git:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git thp/refcounting/v4
> > 
> 
> Hi Kirill,
> 
> I ran some ltp tests and it triggered two bugs:

Okay. The root of both is change in page_mapped(). I'll think how to fix
this.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
