Message-ID: <45117AB6.5040403@yahoo.com.au>
Date: Thu, 21 Sep 2006 03:30:30 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch00/05]: Containers(V2)- Introduction
References: <1158718568.29000.44.camel@galaxy.corp.google.com>	 <4510D3F4.1040009@yahoo.com.au> <1158751720.8970.67.camel@twins>	 <4511626B.9000106@yahoo.com.au> <1158767787.3278.103.camel@taijtu>	 <451173B5.1000805@yahoo.com.au> <1158773800.7705.21.camel@localhost.localdomain>
In-Reply-To: <1158773800.7705.21.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, rohitseth@google.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> Ar Iau, 2006-09-21 am 03:00 +1000, ysgrifennodd Nick Piggin:
> 
>> > I've been thinking a bit on that problem, and it would be possible to
>> > share all address_space pages equally between attached containers, this
>> > would lose some accuracy, since one container could read 10% of the file
>> > and another 90%, but I don't think that is a common scenario.
>>
>>
>>Yeah, I'm not sure about that. I don't think really complex schemes
>>are needed... but again I might need more knowledge of their workloads
>>and problems.
> 
> 
> Any scenario which permits "cheating" will be a scenario that happens
> because people will try and cheat.

That's true, and that's one reason why I've advocated the solution
implemented by Rohit's patches, that is: just throw in the towel and
be happy to count just pages.

Look at the beancounter stuff, and it has hooks (in the form of gfp
flags) throughput the tree, and they still manage to miss accounting
user exploitable memory overallocation from some callers. Maintaining
that will be much more difficult and error prone.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
