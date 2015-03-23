Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2986B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 16:08:47 -0400 (EDT)
Received: by pagv19 with SMTP id v19so26716535pag.2
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 13:08:47 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id vi11si2550863pab.48.2015.03.23.13.08.46
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 13:08:46 -0700 (PDT)
Date: Mon, 23 Mar 2015 16:08:42 -0400 (EDT)
Message-Id: <20150323.160842.746728270630955268.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <21776.28626.30072.920618@quad.stoffel.home>
References: <21776.17527.912997.355420@quad.stoffel.home>
	<20150323.151613.1149103262130397921.davem@davemloft.net>
	<21776.28626.30072.920618@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john@stoffel.org
Cc: david.ahern@oracle.com, torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: "John Stoffel" <john@stoffel.org>
Date: Mon, 23 Mar 2015 15:56:02 -0400

>>>>>> "David" == David Miller <davem@davemloft.net> writes:
> 
> David> From: "John Stoffel" <john@stoffel.org>
> David> Date: Mon, 23 Mar 2015 12:51:03 -0400
> 
>>> Would it make sense to have some memmove()/memcopy() tests on bootup
>>> to catch problems like this?  I know this is a strange case, and
>>> probably not too common, but how hard would it be to wire up tests
>>> that go through 1 to 128 byte memmove() on bootup to make sure things
>>> work properly?
>>> 
>>> This seems like one of those critical, but subtle things to be
>>> checked.  And doing it only on bootup wouldn't slow anything down and
>>> would (ideally) automatically get us coverage when people add new
>>> archs or update the code.
> 
> David> One of two things is already happening.
> 
> David> There have been assembler memcpy/memset development test harnesses
> David> around that most arch developers are using, and those test things
> David> rather extensively.
> 
> David> Also, the memcpy/memset routines on sparc in particular are completely
> David> shared with glibc, we use the same exact code in both trees.  So it's
> David> getting tested there too.
> 
> Thats' good to know.   I wasn't sure.
> 
> David> memmove() is just not handled this way.
> 
> Bummers.  So why isn't this covered by the glibc tests too?

Because the kernel's memmove() is different from the one we use in glibc
on sparc.  In fact, we use the generic C version in glibc which expands
to forward and backward word copies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
