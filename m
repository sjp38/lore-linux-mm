Message-ID: <45B39539.8020704@surriel.com>
Date: Sun, 21 Jan 2007 11:30:49 -0500
From: Rik van Riel <riel@surriel.com>
MIME-Version: 1.0
Subject: Re: Possible ways of dealing with OOM conditions.
References: <20070118104144.GA20925@2ka.mipt.ru> <1169122724.6197.50.camel@twins> <20070118135839.GA7075@2ka.mipt.ru> <1169133052.6197.96.camel@twins> <20070118155003.GA6719@2ka.mipt.ru> <1169141513.6197.115.camel@twins> <20070118183430.GA3345@2ka.mipt.ru> <1169211195.6197.143.camel@twins> <20070119225643.GA22728@2ka.mipt.ru> <45B29953.5010505@surriel.com> <20070121014644.GA12070@2ka.mipt.ru>
In-Reply-To: <20070121014644.GA12070@2ka.mipt.ru>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Evgeniy Polyakov wrote:
> On Sat, Jan 20, 2007 at 05:36:03PM -0500, Rik van Riel (riel@surriel.com) wrote:
>> Evgeniy Polyakov wrote:
>>> On Fri, Jan 19, 2007 at 01:53:15PM +0100, Peter Zijlstra 
>>> (a.p.zijlstra@chello.nl) wrote:
>>>>> Even further development of such idea is to prevent such OOM condition
>>>>> at all - by starting swapping early (but wisely) and reduce memory
>>>>> usage.
>>>> These just postpone execution but will not avoid it.
>>> No. If system allows to have such a condition, then
>>> something is broken. It must be prevented, instead of creating special
>>> hacks to recover from it.
>> Evgeniy, you may want to learn something about the VM before
>> stating that reality should not occur.
> 
> I.e. I should start believing that OOM can not be prevented, bugs can
> not be fixed and things can not be changed just because it happens right
> now? That is why I'm not subscribed to lkml :)

The reasons for this are often not inside the VM itself,
but are due to the constraints imposed on the VM.

For example, with many of the journaled filesystems there
is no way to know in advance how much IO needs to be done
to complete a writeout of one dirty page (and consequently,
how much memory needs to be allocated to complete this one
writeout).

Parts of the VM could be changed to reduce the pressure
somewhat, eg. limiting the number of IOs in flight, but
that will probably have performance consequences that may
not be acceptable to Andrew and Linus and never get merged.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
