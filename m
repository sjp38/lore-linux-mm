Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4CF46B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 04:04:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c2-v6so10955837edi.20
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 01:04:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10-v6si6860877edl.132.2018.07.12.01.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 01:04:21 -0700 (PDT)
Date: Thu, 12 Jul 2018 10:04:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for
 large mapping
Message-ID: <20180712080418.GC32648@dhcp22.suse.cz>
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711111052.hbyukcwetmjjpij2@kshutemo-mobl1>
 <3d4c69c9-dd2b-30d2-5bf2-d5b108a76758@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3d4c69c9-dd2b-30d2-5bf2-d5b108a76758@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-07-18 10:04:48, Yang Shi wrote:
[...]
> One approach is to save all the vmas on a separate list, then zap_page_range
> does unmap with this list.

Just detached unmapped vma chain from mm. You can keep the existing
vm_next chain and reuse it.

-- 
Michal Hocko
SUSE Labs
