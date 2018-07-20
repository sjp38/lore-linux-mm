Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id A83796B0006
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:06:32 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q18-v6so8310208pll.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 14:06:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x82-v6sor825283pfe.150.2018.07.20.14.06.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 14:06:30 -0700 (PDT)
Date: Sat, 21 Jul 2018 00:06:26 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
Message-ID: <20180720210626.5bnyddmn4avp2l3x@kshutemo-mobl1>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hughd@google.com, rientjes@google.com, aaron.lu@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jul 21, 2018 at 02:13:50AM +0800, Yang Shi wrote:
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

I don't think that having the knob around is huge maintenance burden.
And since it helped to workaround a security bug relative recently I would
rather keep it.

-- 
 Kirill A. Shutemov
