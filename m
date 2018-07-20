Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1306B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:32:46 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q18-v6so8142938pll.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:32:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p7-v6si2236056plk.293.2018.07.20.12.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 12:32:45 -0700 (PDT)
Date: Fri, 20 Jul 2018 12:32:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
Message-Id: <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
In-Reply-To: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill@shutemov.name, hughd@google.com, rientjes@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 21 Jul 2018 02:13:50 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:

> By digging into the original review, it looks use_zero_page sysfs knob
> was added to help ease-of-testing and give user a way to mitigate
> refcounting overhead.
> 
> It has been a few years since the knob was added at the first place, I
> think we are confident that it is stable enough. And, since commit
> 6fcb52a56ff60 ("thp: reduce usage of huge zero page's atomic counter"),
> it looks refcounting overhead has been reduced significantly.
> 
> Other than the above, the value of the knob is always 1 (enabled by
> default), I'm supposed very few people turn it off by default.
> 
> So, it sounds not worth to still keep this knob around.

Probably OK.  Might not be OK, nobody knows.

It's been there for seven years so another six months won't kill us. 
How about as an intermediate step we add a printk("use_zero_page is
scheduled for removal.  Please contact linux-mm@kvack.org if you need
it").
