Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91E096B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:35:36 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y17so1935334qth.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:35:36 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r64si3878284qkf.331.2018.03.20.14.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:35:35 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: prevent hugetlb VMA to be misaligned
From: Mike Kravetz <mike.kravetz@oracle.com>
References: <1521566754-30390-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <86240c1a-d1f1-0f03-855e-c5196762ec0a@oracle.com>
Message-ID: <0d24f817-303a-7b4d-4603-b2d14e4b391a@oracle.com>
Date: Tue, 20 Mar 2018 14:35:28 -0700
MIME-Version: 1.0
In-Reply-To: <86240c1a-d1f1-0f03-855e-c5196762ec0a@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, mhocko@kernel.org, Dan Williams <dan.j.williams@intel.com>

On 03/20/2018 02:26 PM, Mike Kravetz wrote:
> Thanks Laurent!
> 
> This bug was introduced by 31383c6865a5.  Dan's changes for 31383c6865a5
> seem pretty straight forward.  It simply replaces an explicit check when
> splitting a vma to a new vm_ops split callout.  Unfortunately, mappings
> created via shmget/shmat have their vm_ops replaced.  Therefore, this
> split callout is never made.
> 
> The shm vm_ops do indirectly call the original vm_ops routines as needed.
> Therefore, I would suggest a patch something like the following instead.
> If we move forward with the patch, we should include Laurent's BUG output
> and perhaps test program in the commit message.

Sorry, patch in previous mail was a mess
