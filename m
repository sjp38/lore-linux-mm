Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3BB6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 07:09:59 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so20544083wic.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:09:58 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id b19si15553620wiw.16.2015.08.10.04.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 04:09:57 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so17630441wic.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:09:57 -0700 (PDT)
Date: Mon, 10 Aug 2015 14:09:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page-flags behavior on compound pages: a worry
Message-ID: <20150810110955.GA27046@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
 <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
 <alpine.DEB.2.11.1508061542200.8172@east.gentwo.org>
 <20150807145056.GB12177@node.dhcp.inet.fi>
 <alpine.DEB.2.11.1508071022160.14912@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1508071022160.14912@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 07, 2015 at 10:28:49AM -0500, Christoph Lameter wrote:
> On Fri, 7 Aug 2015, Kirill A. Shutemov wrote:
> 
> > On Thu, Aug 06, 2015 at 03:45:31PM -0500, Christoph Lameter wrote:
> > > On Thu, 6 Aug 2015, Hugh Dickins wrote:
> > >
> > > > > I know a patchset which solves this! ;)
> > > >
> > > > Oh, and I know a patchset which avoids these problems completely,
> > > > by not using compound pages at all ;)
> > >
> > > Another dumb idea: Stop the insanity of splitting pages on the fly?
> > > Splitting pages should work like page migration: Lock everything down and
> > > ensure no one is using the page and then do it. That way the compound pages
> > > and its metadata are as stable as a regular page.
> >
> > That's what I do in refcounting patchset.
> 
> Looks like you make refcounting easier and avoid splitting in some cases
> maybe only splitting the pmd. But the fundamental issue still remains.
> Complexity is high since individual pages of a compound can be mapped and
> unmapped in multiple processes.
> 
> The compound would need to be always treated as a single order N entity
> in order to really get things simplified and make code cleaner.
> 
> Either all pages are mapped or none. Otherwise you have to manage the
> a schizoprenic view of pages. Sometimes an order N size entity is
> managed and sometimes a base page size page which is a fraction of the
> whole. Such a view of a memory object is pretty difficult to manage.

I don't see anything actionable here. Your wish list doesn't cope with
reality. Compound pages are mapped with PTEs for almost ten years and I
don't see why we should stop the practice.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
