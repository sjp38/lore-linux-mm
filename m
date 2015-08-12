Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6CF6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 10:35:27 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so32280900wib.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 07:35:26 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id bf10si10954226wib.3.2015.08.12.07.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 07:35:12 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so221133996wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 07:35:12 -0700 (PDT)
Date: Wed, 12 Aug 2015 17:35:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: page-flags behavior on compound pages: a worry
Message-ID: <20150812143509.GA12320@node.dhcp.inet.fi>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.LSU.2.11.1508052001350.6404@eggly.anvils>
 <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1508061121120.7500@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 06, 2015 at 12:24:22PM -0700, Hugh Dickins wrote:
> > IIUC, the only potentially problematic callsites left are physical memory
> > scanners. This code requires audit. I'll do that.
> 
> Please.

I haven't finished the exercise yet. But here's an issue I believe present
in current *Linus* tree:
