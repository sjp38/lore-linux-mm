Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 968956B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 15:26:47 -0400 (EDT)
Received: by wetk59 with SMTP id k59so65541704wet.3
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 12:26:47 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id a2si3751388wjs.97.2015.03.19.12.26.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 12:26:46 -0700 (PDT)
Date: Thu, 19 Mar 2015 20:26:44 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/memory-failure.c: define page types for
 action_result() in one place
Message-ID: <20150319192644.GD22151@two.firstfloor.org>
References: <1426746272-24306-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426746272-24306-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Xie XiuQi <xiexiuqi@huawei.com>, Steven Rostedt <rostedt@goodmis.org>, Chen Gong <gong.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Mar 19, 2015 at 06:24:35AM +0000, Naoya Horiguchi wrote:
> This cleanup patch moves all strings passed to action_result() into a single
> array action_page_type so that a reader can easily find which kind of action
> results are possible. And this patch also fixes the odd lines to be printed
> out, like "unknown page state page" or "free buddy, 2nd try page".
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Looks good

Reviewed-by: Andi Kleen <ak@linux.intel.com>

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
