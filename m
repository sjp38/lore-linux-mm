Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 827956B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:56:09 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so73677106wib.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:56:09 -0700 (PDT)
Received: from mailrelay3.lanline.com (mailrelay3.lanline.com. [216.187.10.24])
        by mx.google.com with ESMTPS id wr1si2980841wjb.25.2015.03.23.12.56.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 12:56:07 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <21776.28626.30072.920618@quad.stoffel.home>
Date: Mon, 23 Mar 2015 15:56:02 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: 4.0.0-rc4: panic in free_block
In-Reply-To: <20150323.151613.1149103262130397921.davem@davemloft.net>
References: <20150322.221906.1670737065885267482.davem@davemloft.net>
	<20150323.122530.812870422534676208.davem@davemloft.net>
	<21776.17527.912997.355420@quad.stoffel.home>
	<20150323.151613.1149103262130397921.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: john@stoffel.org, david.ahern@oracle.com, torvalds@linux-foundation.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bpicco@meloft.net

>>>>> "David" == David Miller <davem@davemloft.net> writes:

David> From: "John Stoffel" <john@stoffel.org>
David> Date: Mon, 23 Mar 2015 12:51:03 -0400

>> Would it make sense to have some memmove()/memcopy() tests on bootup
>> to catch problems like this?  I know this is a strange case, and
>> probably not too common, but how hard would it be to wire up tests
>> that go through 1 to 128 byte memmove() on bootup to make sure things
>> work properly?
>> 
>> This seems like one of those critical, but subtle things to be
>> checked.  And doing it only on bootup wouldn't slow anything down and
>> would (ideally) automatically get us coverage when people add new
>> archs or update the code.

David> One of two things is already happening.

David> There have been assembler memcpy/memset development test harnesses
David> around that most arch developers are using, and those test things
David> rather extensively.

David> Also, the memcpy/memset routines on sparc in particular are completely
David> shared with glibc, we use the same exact code in both trees.  So it's
David> getting tested there too.

Thats' good to know.   I wasn't sure.

David> memmove() is just not handled this way.

Bummers.  So why isn't this covered by the glibc tests too?  Not
accusing, not at all!  Just wondering.  

Thanks for all your work David, I've been amazed at your energy here!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
