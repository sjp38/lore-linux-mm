Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 057B86B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 05:55:48 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id f4so3773341oah.35
        for <linux-mm@kvack.org>; Fri, 26 Apr 2013 02:55:48 -0700 (PDT)
Message-ID: <517A4F1E.9070803@gmail.com>
Date: Fri, 26 Apr 2013 17:55:42 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: vmalloc fault
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>

Hi all,

1. Why vmalloc fault need sync user process page table with kernel page 
table instead of using kernel page table directly?

2. Why do_swap_page doesn't set present flag?

3. When enable DEBUG_PAGEALLOC(catch use-after-free bug), if user 
process alloc pages from zone_normal(which is direct mapping) when 
fallback, this page which allocated for user process will set present 
flag in related pte, correct? but why also set present flag for kernel 
direct mapping? Does kernel have any requirement to access it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
