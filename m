Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 984AE6B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 07:58:42 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so59584751wgy.2
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:58:42 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id eq3si2544067wjd.142.2015.04.30.04.58.40
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 04:58:41 -0700 (PDT)
Date: Thu, 30 Apr 2015 14:58:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 16/28] mm, thp: remove compound_lock
Message-ID: <20150430115828.GB15874@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-17-git-send-email-kirill.shutemov@linux.intel.com>
 <5541029C.60207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5541029C.60207@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 29, 2015 at 06:11:08PM +0200, Jerome Marchand wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> > We are going to use migration entries to stabilize page counts. It means
> 
> By "stabilize" do you mean "protect" from concurrent access? I've seen
> that you use the same term in seemingly the same sense several times (at
> least in patches 15, 16, 23, 24 and 28).

Here it's protect from concurrent change of page's ->_count or
->_mapcount.

In some context I could you "stabilize" as "protect from concurrent
split".
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
