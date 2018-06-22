Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD5C6B000A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:00:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d2-v6so2350367pgq.22
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 01:00:22 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c3-v6si6789826pll.105.2018.06.22.01.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 01:00:21 -0700 (PDT)
Date: Fri, 22 Jun 2018 11:00:20 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [v2 PATCH 2/2] mm: thp: inc counter for collapsed shmem THP
Message-ID: <20180622080020.fefoaywh77adp5hm@black.fi.intel.com>
References: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529622949-75504-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529622949-75504-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yang.shi@linux.alibaba.com
Cc: hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 21, 2018 at 11:15:49PM +0000, yang.shi@linux.alibaba.com wrote:
> /sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed is used
> to record the counter of collapsed THP, but it just gets inc'ed in
> anonymous THP collapse path, do this for shmem THP collapse too.
> 
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
