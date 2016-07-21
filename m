Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 753A66B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:38:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b62so18087114pfa.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:38:47 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id z4si10192000pfi.24.2016.07.21.07.38.46
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 07:38:46 -0700 (PDT)
Subject: Re: [PATCH] make __section_nr more efficient
References: <1468988310-11560-1-git-send-email-zhouchengming1@huawei.com>
 <578FEEC4.9060209@intel.com> <57902B8A.8040907@huawei.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5790DE74.3080907@intel.com>
Date: Thu, 21 Jul 2016 07:38:44 -0700
MIME-Version: 1.0
In-Reply-To: <57902B8A.8040907@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouchengming <zhouchengming1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, tj@kernel.org, guohanjun@huawei.com, huawei.libin@huawei.com

On 07/20/2016 06:55 PM, zhouchengming wrote:
> Thanks for your reply. I don't know the compiler will optimize the loop.
> But when I see the assembly code of __section_nr, it seems to still have
> the loop in it.

Oh, well.  I guess it got broken in the last decade or so.  Your patch
looks good to me, and the fact that we ended up here means the original
approach was at least a little fragile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
