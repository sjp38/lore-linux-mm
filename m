Message-ID: <46A81C39.4050009@gmail.com>
Date: Thu, 26 Jul 2007 05:59:53 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com>	 <46A773EA.5030103@gmail.com> <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
In-Reply-To: <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Deaton <false.hopes@gmail.com>
Cc: linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/25/2007 07:15 PM, Robert Deaton wrote:

> On 7/25/07, Rene Herman <rene.herman@gmail.com> wrote:

>> And there we go again -- off into blabber-land. Why does swap-prefetch 
>> help updatedb? Or doesn't it? And if it doesn't, why should anyone 
>> trust anything else someone who said it does says?

> I don't think anyone has ever argued that swap-prefetch directly helps 
> the performance of updatedb in any way

People have argued (claimed, rather) that swap-prefetch helps their system 
after updatedb has run -- you are doing so now.

> however, I do recall people mentioning that updatedb, being a ram
> intensive task, will often cause things to be swapped out while it runs
> on say a nightly cronjob.

Problem spot no. 1.

RAM intensive? If I run updatedb here, it never grows itself beyond 2M. Yes, 
two. I'm certainly willing to accept that me and my systems are possibly not 
the reference but assuming I'm _very_ special hasn't done much for me either 
in the past.

The thing updatedb does do, or at least has the potential to do, is fill 
memory with cached inodes/dentries but Linux does not swap to make room for 
caches. So why will updatedb "often cause things to be swapped out"?

[ snip ]

> Swap prefetch, on the other hand, would have kicked in shortly after
> updatedb finished, leaving the applications in swap for a speedy
> recovery when the person comes back to their computer.

Problem spot no. 2.

If updatedb filled all of RAM with inodes/dentries, that RAM is now used 
(ie, not free) and swap-prefetch wouldn't have anywhere to prefetch into so 
would _not_ have kicked in.

So what's happening? If you sit down with a copy op "top" in one terminal 
and updatedb in another, what does it show?

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
