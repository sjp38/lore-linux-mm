Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id D1C096B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 06:54:53 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so32530372igb.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 03:54:53 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id m2si10557748igr.10.2015.10.09.03.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 03:54:53 -0700 (PDT)
Subject: Re: [PATCH v2 10/12] mm,thp: introduce flush_pmd_tlb_range
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
 <1442918096-17454-11-git-send-email-vgupta@synopsys.com>
 <20151009100816.GC7873@node>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56179CE5.5000807@synopsys.com>
Date: Fri, 9 Oct 2015 16:24:29 +0530
MIME-Version: 1.0
In-Reply-To: <20151009100816.GC7873@node>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Friday 09 October 2015 03:38 PM, Kirill A. Shutemov wrote:
> On Tue, Sep 22, 2015 at 04:04:54PM +0530, Vineet Gupta wrote:
> 
> Commit message: -ENOENT.
> 
> Otherwise, looks good:
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

With updated change log and some reworking in the source code comment !

---------------->
