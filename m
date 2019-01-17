Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 752578E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:35:03 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id a12so7384740iok.8
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 05:35:03 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r4si889445ita.11.2019.01.17.05.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 05:35:02 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm/page_alloc: check return value of
 memblock_alloc_node_nopanic()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190117112611.GB3710@rapoport-lnx>
Date: Thu, 17 Jan 2019 06:34:57 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <971266DB-8F42-4189-A561-2C8A708A4D1B@oracle.com>
References: <1547621481-8374-1-git-send-email-rppt@linux.ibm.com>
 <5195030D-7ED9-4074-AB6C-92A3AFF11E00@oracle.com>
 <20190117112611.GB3710@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 17, 2019, at 4:26 AM, Mike Rapoport <rppt@linux.ibm.com> wrote:
> 
> On Thu, Jan 17, 2019 at 03:19:35AM -0700, William Kucharski wrote:
>> 
>> This seems very reasonable, but if the code is just going to panic if the
>> allocation fails, why not call memblock_alloc_node() instead?
> 
> I've sent patches [1] that remove panic() from memblock_alloc*() and drop
> _nopanic variants. After they will be (hopefully) merged,
> memblock_alloc_node() will return NULL on error.
> 
>> If there is a reason we'd prefer to call memblock_alloc_node_nopanic(),
>> I'd like to see pgdat->nodeid printed in the panic message as well.
> 
> Sure.

Thanks for the quick response.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
