Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF4A06B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:42:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 89so13349682wrr.2
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:42:10 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id u15si6219604wmf.119.2017.02.23.01.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 01:42:09 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id v77so6364109wmv.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:42:09 -0800 (PST)
Date: Thu, 23 Feb 2017 12:42:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/thp/autonuma: Use TNF flag instead of vm fault.
Message-ID: <20170223094205.GA32251@node.shutemov.name>
References: <1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 19, 2017 at 03:29:55PM +0530, Aneesh Kumar K.V wrote:
> We are using wrong flag value in task_numa_falt function. This can result in
> us doing wrong numa fault statistics update, because we update num_pages_migrate
> and numa_fault_locality etc based on the flag argument passed.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Ouch. My bad.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
