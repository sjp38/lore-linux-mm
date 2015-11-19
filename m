Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 971846B0253
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 20:00:10 -0500 (EST)
Received: by padhx2 with SMTP id hx2so61814335pad.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 17:00:10 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id vs7si7794133pab.78.2015.11.18.17.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 17:00:09 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so63870426pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 17:00:08 -0800 (PST)
Date: Wed, 18 Nov 2015 17:00:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, vmalloc: remove VM_VPAGES
In-Reply-To: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
References: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Nov 2015, kbuild test robot wrote:

> Hi David,
> 
> [auto build test ERROR on: next-20151118]
> [also build test ERROR on: v4.4-rc1]
> 

You need to teach your bot what patches I'm proposing for the -mm tree 
(notice the patch title) instead of your various trees.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
