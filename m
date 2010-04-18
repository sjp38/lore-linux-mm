Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EE4A46B01EF
	for <linux-mm@kvack.org>; Sun, 18 Apr 2010 19:33:39 -0400 (EDT)
Date: Sun, 18 Apr 2010 19:34:09 -0400
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: "Sorin Faibish" <sfaibish@emc.com>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
MIME-Version: 1.0
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard>
 <20100415102837.GB10966@csn.ul.ie> <20100416041412.GY2493@dastard>
 <20100416151403.GM19264@csn.ul.ie>
 <20100417203239.dda79e88.akpm@linux-foundation.org>
 <op.vbdgq3hhrwwil4@sfaibish1.corp.emc.com>
 <1271626236.27350.70.camel@mulgrave.site>
Content-Transfer-Encoding: 8bit
Message-ID: <op.vbds27xqrwwil4@sfaibish1.corp.emc.com>
In-Reply-To: <1271626236.27350.70.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 18 Apr 2010 17:30:36 -0400, James Bottomley  
<James.Bottomley@suse.de> wrote:

> On Sun, 2010-04-18 at 15:10 -0400, Sorin Faibish wrote:
>> On Sat, 17 Apr 2010 20:32:39 -0400, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>
>> >
>> > There are two issues here: stack utilisation and poor IO patterns in
>> > direct reclaim.  They are different.
>> >
>> > The poor IO patterns thing is a regression.  Some time several years
>> > ago (around 2.6.16, perhaps), page reclaim started to do a LOT more
>> > dirty-page writeback than it used to.  AFAIK nobody attempted to work
>> > out why, nor attempted to try to fix it.
>
>> I for one am looking very seriously at this problem together with Bruce.
>> We plan to have a discussion on this topic at the next LSF meeting
>> in Boston.
>
> As luck would have it, the Memory Management summit is co-located with
> the Storage and Filesystem workshop ... how about just planning to lock
> all the protagonists in a room if it's not solved by August.  The less
> extreme might even like to propose topics for the plenary sessions ...
Let's work together to get this done. This is a very good idea. I will try
to bring some facts about the current state by instrumenting the kernel
to sample with higher time granularity the dirty pages dynamics. This will
allow us expose better the problem or lack of. :)

/Sorin


>
> James
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 
Best Regards
Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

        EMC2
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
