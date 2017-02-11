Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70A136B038B
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:24:12 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id t84so44714636qke.7
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:24:12 -0800 (PST)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id 1si2604850qkl.320.2017.02.10.18.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 18:24:11 -0800 (PST)
Received: by mail-qk0-x242.google.com with SMTP id u25so7359136qki.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 18:24:11 -0800 (PST)
Date: Sat, 11 Feb 2017 11:24:00 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm/sparse: add last_section_nr in sparse_init()
 to reduce some iteration cycle
Message-ID: <20170211022400.GA19050@mtj.duckdns.org>
References: <20170211021829.9646-1-richard.weiyang@gmail.com>
 <20170211021829.9646-2-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170211021829.9646-2-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Sat, Feb 11, 2017 at 10:18:29AM +0800, Wei Yang wrote:
> During the sparse_init(), it iterate on each possible section. On x86_64,
> it would always be (2^19) even there is not much memory. For example, on a
> typical 4G machine, it has only (2^5) to (2^6) present sections. This
> benefits more on a system with smaller memory.
> 
> This patch calculates the last section number from the highest pfn and use
> this as the boundary of iteration.

* How much does this actually matter?  Can you measure the impact?

* Do we really need to add full reverse iterator to just get the
  highest section number?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
