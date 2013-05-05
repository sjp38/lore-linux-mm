Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A56D66B029C
	for <linux-mm@kvack.org>; Sun,  5 May 2013 05:27:52 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq12so1569399pab.12
        for <linux-mm@kvack.org>; Sun, 05 May 2013 02:27:51 -0700 (PDT)
Received: from eeebox.branda.to (123-194-58-207.dynamic.kbronet.com.tw. [123.194.58.207])
        by mx.google.com with ESMTPSA id sa6sm19060940pbb.26.2013.05.05.02.27.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 05 May 2013 02:27:50 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by eeebox.branda.to (8.14.5/8.14.7) with ESMTP id r459TfbV052622
	for <linux-mm@kvack.org>; Sun, 5 May 2013 17:29:41 +0800 (CST)
	(envelope-from thinker@branda.to)
Date: Sun, 05 May 2013 17:29:40 +0800 (CST)
Message-Id: <20130505.172940.288523891.thinker@eeebox.branda.to>
Subject: How to make TLB been flushed?
From: "Thinker K.F. Li" <thinker@codemud.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I am working on COW features to allow processes mapping anonymous
pages from a source address to another target address, in the same
process or crossing processes, so both the source and the target would
be shared and COW.  So, we can implement memcpy() with COW for big
chunks of memory, to reduce traffic of memory bus and memory
consumption.

My question is how to flush TLB after change pte entries?

I have implemented my idea as a kernel module.  I have read
Documents/cacheflush.txt, and try to call flush_tlb_range() or
flush_tlb_all(), but their symbols are not exported, they can not be
used by kernel module code.  Is there any other way to flush TLB?  Or
I should implement it as a part of kernel instead of as a kernel
module.!?

For now, my temporary solution is to change kernel code to export
symbols that I need.

I had tested the code on my desktop and qemu, but I am not sure it is
100% right.  There are some known issues; for example, rmap.  But, it
can run now.  So, I also need testing, review and feedback from people
here to make it more mature.

You can find the source here,

    https://bitbucket.org/thinker/memcow

Any feedback is welcomed!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
