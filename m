Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC436B01AD
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:20:09 -0400 (EDT)
Date: Sun, 13 Jun 2010 12:19:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.35-rc2: GPF while executing libhugetlbfs tests on x86_64
Message-ID: <20100613111944.GA22015@csn.ul.ie>
References: <4C0BC7F0.8030109@in.ibm.com> <20100608091817.GA27717@csn.ul.ie> <4C0E2E84.6060605@in.ibm.com> <20100608123622.GE27717@csn.ul.ie> <4C11CA71.9010606@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4C11CA71.9010606@in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Sachin Sant <sachinp@in.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 11, 2010 at 11:02:33AM +0530, Sachin Sant wrote:
> Mel Gorman wrote:
>> If the problem has gone away since 2.6.35-rc2, the most likely candidate fix
>> patch is commit [386f40: Revert "tty: fix a little bug in scrup, vt.c"] which
>> reverts the patch you previously identified as being a problem.  The commit
>> message also matches roughly what you are seeing with the 0x0720 patterns.
>>
>> Can you retest with 2.6.35-rc2 with commit 386f40 applied and see if it
>> also fixes up your problem please?
>>   
> I could not recreate this problem against 2.6.35-rc2 + commit 386f40.
>

Great, I will consider this bug resolved so. Thanks for testing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
