Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 989266B004D
	for <linux-mm@kvack.org>; Sun,  4 Nov 2012 06:26:40 -0500 (EST)
Message-ID: <509650EA.5060508@redhat.com>
Date: Sun, 04 Nov 2012 12:26:34 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <507688CC.9000104@suse.cz> <106695.1349963080@turing-police.cc.vt.edu> <5076E700.2030909@suse.cz> <118079.1349978211@turing-police.cc.vt.edu> <50770905.5070904@suse.cz> <119175.1349979570@turing-police.cc.vt.edu> <5077434D.7080008@suse.cz> <50780F26.7070007@suse.cz> <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz>
In-Reply-To: <509422C3.1000803@suse.cz>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Dne 2.11.2012 20:45, Jiri Slaby napsal(a):
> On 11/02/2012 11:53 AM, Jiri Slaby wrote:
>> On 11/02/2012 11:44 AM, Zdenek Kabelac wrote:
>>>>> Yes, applying this instead of the revert fixes the issue as well.
>>>
>>> I've applied this patch on 3.7.0-rc3 kernel - and I still see excessive
>>> CPU usage - mainly  after  suspend/resume
>>>
>>> Here is just simple  kswapd backtrace from running kernel:
>>
>> Yup, this is what we were seeing with the former patch only too. Try to
>> apply the other one too:
>> https://patchwork.kernel.org/patch/1673231/
>>
>> For me I would say, it is fixed by the two patches now. I won't be able
>> to report later, since I'm leaving to a conference tomorrow.
>
> Damn it. It recurred right now, with both patches applied. After I
> started a java program which consumed some more memory. Though there are
> still 2 gigs free, kswap is spinning:
> [<ffffffff810b00da>] __cond_resched+0x2a/0x40
> [<ffffffff811318a0>] shrink_slab+0x1c0/0x2d0
> [<ffffffff8113478d>] kswapd+0x66d/0xb60
> [<ffffffff810a25d0>] kthread+0xc0/0xd0
> [<ffffffff816aa29c>] ret_from_fork+0x7c/0xb0
> [<ffffffffffffffff>] 0xffffffffffffffff
>

Yep - wanted to report myself again and noticed your replay.

Yes - I've now also both patches installed - and I still observe kswapd eating 
my CPU.  It seems (at least for me) that  prior suspend and resume is way to 
trigger it more frequently.

However there is a change in behaviour - while before kswapd was running 
almost indefinitely now the> CPU spikes are in the range of minutes.
(i.e. uptime  ~2days -   kswapd has over 32minutes CPU time)
My machine has 4GB, and no swap (disabled)

firefox (22mins), thunderbird(3mins) and pidgin(0.5min) are the 3 most memory 
and CPU hungry apps for this moment.

Zdenek


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
