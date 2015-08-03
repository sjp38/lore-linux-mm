Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9123F6B025D
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 06:53:31 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so130326755wic.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:53:31 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id r9si13231575wiz.76.2015.08.03.03.53.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 03:53:29 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so130648865wib.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:53:29 -0700 (PDT)
Date: Mon, 3 Aug 2015 13:53:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9 30/36] thp: add option to setup migration entiries
 during PMD split
Message-ID: <20150803105327.GD25034@node.dhcp.inet.fi>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1437402069-105900-31-git-send-email-kirill.shutemov@linux.intel.com>
 <55BB8FB2.6040004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55BB8FB2.6040004@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 31, 2015 at 05:09:38PM +0200, Jerome Marchand wrote:
> On 07/20/2015 04:21 PM, Kirill A. Shutemov wrote:
> > We are going to use migration PTE entires to stabilize page counts.
> > If the page is mapped with PMDs we need to split the PMD and setup
> > migration enties. It's reasonable to combine these operations to avoid
> > double-scanning over the page table.
> 
> Entries? Three different typos for three occurrences of the same word.
> You don't like it, do you?

Urgh..
