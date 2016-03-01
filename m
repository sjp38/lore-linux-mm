Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 424616B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 07:09:23 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id l68so33417168wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:09:23 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id wd3si37041054wjc.88.2016.03.01.04.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 04:09:22 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id n186so33496042wmn.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:09:22 -0800 (PST)
Date: Tue, 1 Mar 2016 15:09:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301120919.GA19559@node.shutemov.name>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
 <20160301110055.GK2747@suse.de>
 <20160301115136.GL2747@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301115136.GL2747@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Mar 01, 2016 at 11:51:36AM +0000, Mel Gorman wrote:
> While I know some of these points can be countered and discussed further,
> at the end of the day, the benefits to huge page usage are reduced memory
> usage on page tables, a reduction of TLB pressure and reduced TLB fill
> costs. Until such time as it's known that there are realistic workloads
> that cannot fit in memory due to the page table usage and workloads that
> are limited by TLB pressure, the complexity of huge pages is unjustified
> and the focus should be on the basic features working correctly.

Size of page table can be limiting factor now for workloads that tries to
migrate from 2M hugetlb with shared page tables to DAX. 1G pages is a way
to lower the overhead.

Note, that reduced memory usage on page tables is not there for anon THP,
as we have to deposit these page table to be able split huge pmd (or pud)
at any point.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
