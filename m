Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCC46B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 18:14:10 -0500 (EST)
Received: by padfa1 with SMTP id fa1so17702488pad.2
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 15:14:09 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fl10si2788377pab.219.2015.02.26.15.14.08
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 15:14:09 -0800 (PST)
Message-ID: <54EFA8BC.5060909@intel.com>
Date: Thu, 26 Feb 2015 15:14:04 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: completely remove dumping per-cpu lists from show_mem()
References: <20150225134426.d907ecb7130d12dc8ad97c90@linux-foundation.org> <20150226061454.24653.49733.stgit@zurg>
In-Reply-To: <20150226061454.24653.49733.stgit@zurg>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.cz>

On 02/25/2015 10:14 PM, Konstantin Khlebnikov wrote:
> It seems nobody needs this.

Yay!

I was just digging through an OOM on a system with 288 logical CPUs.  It
sucked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
