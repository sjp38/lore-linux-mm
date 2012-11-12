Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id DA2EC6B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 08:13:28 -0500 (EST)
Message-ID: <50A0F5F0.6090400@redhat.com>
Date: Mon, 12 Nov 2012 14:13:20 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz> <509C84ED.8090605@linux.vnet.ibm.com> <509CB9D1.6060704@redhat.com> <20121109090635.GG8218@suse.de> <509F6C2A.9060502@redhat.com> <20121112121956.GT8218@suse.de>
In-Reply-To: <20121112121956.GT8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

Dne 12.11.2012 13:19, Mel Gorman napsal(a):
> On Sun, Nov 11, 2012 at 10:13:14AM +0100, Zdenek Kabelac wrote:
>> Hmm,  so it's just took longer to hit the problem and observe kswapd0
>> spinning on my CPU again - it's not as endless like before - but
>> still it easily eats minutes - it helps to  turn off  Firefox or TB
>> (memory hungry apps) so kswapd0 stops soon - and restart those apps
>> again.
>> (And I still have like >1GB of cached memory)
>>
>
> I posted a "safe" patch that I believe explains why you are seeing what
> you are seeing. It does mean that there will still be some stalls due to
> THP because kswapd is not helping and it's avoiding the problem rather
> than trying to deal with it.
>
> Hence, I'm also going to post this patch even though I have not tested
> it myself. If you find it fixes the problem then it would be a
> preferable patch to the revert. It still is the case that the
> balance_pgdat() logic is in sort need of a rethink as it's pretty
> twisted right now.
>


Should I apply them all together for 3.7-rc5 ?

1) https://lkml.org/lkml/2012/11/5/308
2) https://lkml.org/lkml/2012/11/12/113
3) https://lkml.org/lkml/2012/11/12/151

Zdenek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
