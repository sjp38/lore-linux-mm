Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93E906B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 17:36:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p64so124685955pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 14:36:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id n82si5423311pfb.202.2016.07.20.14.36.04
        for <linux-mm@kvack.org>;
        Wed, 20 Jul 2016 14:36:04 -0700 (PDT)
Subject: Re: [PATCH] make __section_nr more efficient
References: <1468988310-11560-1-git-send-email-zhouchengming1@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <578FEEC4.9060209@intel.com>
Date: Wed, 20 Jul 2016 14:36:04 -0700
MIME-Version: 1.0
In-Reply-To: <1468988310-11560-1-git-send-email-zhouchengming1@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhou Chengming <zhouchengming1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tj@kernel.org, guohanjun@huawei.com, huawei.libin@huawei.com

On 07/19/2016 09:18 PM, Zhou Chengming wrote:
> When CONFIG_SPARSEMEM_EXTREME is disabled, __section_nr can get
> the section number with a subtraction directly.

Does this actually *do* anything?

It was a long time ago, but if I remember correctly, the entire loop in
__section_nr() goes away because root_nr==NR_SECTION_ROOTS, so
root_nr=1, and the compiler optimizes away the entire subtraction.

So this basically adds an #ifdef and gets us nothing, although it makes
the situation much more explicit.  Perhaps the comment should say that
this works *and* is efficient because the compiler can optimize all the
extreme complexity away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
