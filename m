Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2105B6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:16:17 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so196368937pdb.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:16:16 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id k2si2060594pdj.249.2015.03.23.12.16.16
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 12:16:16 -0700 (PDT)
Date: Mon, 23 Mar 2015 15:16:13 -0400 (EDT)
Message-Id: <20150323.151613.1149103262130397921.davem@davemloft.net>
Subject: Re: 4.0.0-rc4: panic in free_block
From: David Miller <davem@davemloft.net>
In-Reply-To: <21776.17527.912997.355420@quad.stoffel.home>
References: <20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
	<21776.17527.912997.355420@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john@stoffel.org
Cc: david.ahern@oracle.com, torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

From: "John Stoffel" <john@stoffel.org>
Date: Mon, 23 Mar 2015 12:51:03 -0400

> Would it make sense to have some memmove()/memcopy() tests on bootup
> to catch problems like this?  I know this is a strange case, and
> probably not too common, but how hard would it be to wire up tests
> that go through 1 to 128 byte memmove() on bootup to make sure things
> work properly?
> 
> This seems like one of those critical, but subtle things to be
> checked.  And doing it only on bootup wouldn't slow anything down and
> would (ideally) automatically get us coverage when people add new
> archs or update the code.

One of two things is already happening.

There have been assembler memcpy/memset development test harnesses
around that most arch developers are using, and those test things
rather extensively.

Also, the memcpy/memset routines on sparc in particular are completely
shared with glibc, we use the same exact code in both trees.  So it's
getting tested there too.

memmove() is just not handled this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
