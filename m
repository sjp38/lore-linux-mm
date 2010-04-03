Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9876B01F0
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 10:48:59 -0400 (EDT)
Message-ID: <22c901cad333$7a67db60$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <03ca01cacb92$195adf50$0400a8c0@dcccs> <2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com> <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com> <02c101cacbf8$d21d1650$0400a8c0@dcccs> <179901cad182$5f87f620$0400a8c0@dcccs> <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com> <1fe901cad2b0$d39d0300$0400a8c0@dcccs> <20100402230905.GW3335@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Sat, 3 Apr 2010 15:42:10 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

Hello,

The actual version of kernel is 2.6.32.10.
There is any significant fixes for me in the last (.11) or in the next 
(33.x)?

Thanks,
Janos

----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: "Americo Wang" <xiyou.wangcong@gmail.com>; 
<linux-kernel@vger.kernel.org>; "KAMEZAWA Hiroyuki" 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Saturday, April 03, 2010 1:09 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Sat, Apr 03, 2010 at 12:07:00AM +0200, Janos Haar wrote:
>> Hello,
>>
>> ----- Original Message ----- From: "Americo Wang"
>> <xiyou.wangcong@gmail.com>
>> To: "Janos Haar" <janos.haar@netcenter.hu>
>> Cc: <linux-kernel@vger.kernel.org>; "KAMEZAWA Hiroyuki"
>> <kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>;
>> <xfs@oss.sgi.com>; "Jens Axboe" <axboe@kernel.dk>
>> Sent: Thursday, April 01, 2010 12:37 PM
>> Subject: Re: Somebody take a look please! (some kind of kernel bug?)
>>
>>
>> >On Thu, Apr 1, 2010 at 6:01 PM, Janos Haar
>> ><janos.haar@netcenter.hu> wrote:
>> >>Hello,
>> >>
>> >
>> >Hi,
>> >This is a totally different bug from the previous one reported by you. 
>> >:)
>>
>> Today i have got this again, exactly the same. (if somebody wants
>> the log, just ask)
>> There is a cut:
>
> Small hint - please put the subsytemthe bug occurred in in the
> subject line. I missed this in the firehose of lkml traffic because
> there wasnothing to indicate to me it was in XFS. Soemthing like:
>
> "Kernel crash in xfs_iflush_cluster"
>
> Won't get missed quite so easily....
>
> This may be a fixed problem - what kernel are you running?
>
> Cheers,
>
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
