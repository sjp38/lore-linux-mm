Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 921366B0073
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 10:09:20 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so20343930wia.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:09:20 -0700 (PDT)
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id jh6si13021369wid.94.2015.04.07.07.09.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 07:09:19 -0700 (PDT)
Received: by wgbdm7 with SMTP id dm7so57447307wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:09:18 -0700 (PDT)
Message-ID: <5523E50C.4060706@plexistor.com>
Date: Tue, 07 Apr 2015 17:09:16 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3 v6] mm(v4.1): New pfn_mkwrite same as page_mkwrite
 for VM_PFNMAP
References: <55239645.9000507@plexistor.com> <552397E6.5030506@plexistor.com> <5523D43C.1060708@plexistor.com> <20150407131700.GA13946@node.dhcp.inet.fi> <20150407132601.GA14252@node.dhcp.inet.fi> <5523DD83.4050609@plexistor.com> <20150407134759.GB14252@node.dhcp.inet.fi>
In-Reply-To: <20150407134759.GB14252@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>, Stable Tree <stable@vger.kernel.org>

On 04/07/2015 04:47 PM, Kirill A. Shutemov wrote:
<>
>> I did not understand if you want that I keep it "return ret".
> 
> I think "return 0;" is right way to go. It matches wp_page_shared()
> behaviour.
> 

Ok I sent a v7 with "return 0;" as is in wp_page_shared(). I guess
it is better. It survived of course an xfstests quick but I'll let
it smoke for the night as well.

Thanks for all your help
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
