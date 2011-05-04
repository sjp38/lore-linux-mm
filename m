Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3CC06B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 22:45:46 -0400 (EDT)
Received: by wwi36 with SMTP id 36so646764wwi.26
        for <linux-mm@kvack.org>; Tue, 03 May 2011 19:45:42 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 4 May 2011 10:45:42 +0800
Message-ID: <BANLkTiko7N=1w+Z56vuDcAUw5cHwgPi=1g@mail.gmail.com>
Subject: COW page cache for file hole?
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>

Hi,

During test fengguang's readahead alloc-noretry patch, I have some thoughts

In the 1000 dd case, page cache of sparse file hole are all zero indeed.
So what about make a global zero page for that purpose, fs level know
it is a hole,
when write occurs on that page we can alloc a new page for that.

I have no enough knowledge to implement it so just give out the
question without patch, sorry.
BTW, was there any attempt for this before?

-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
