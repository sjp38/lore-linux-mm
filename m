Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BCBD16B021D
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 04:01:31 -0400 (EDT)
Message-ID: <295901cadd3a$fbeb1650$0400a8c0@dcccs>
From: "Janos Haar" <janos.haar@netcenter.hu>
References: <20100408025822.GL11036@dastard> <11b701cad9c8$93212530$0400a8c0@dcccs> <20100412001158.GA2493@dastard> <18b101cadadf$5edbb660$0400a8c0@dcccs> <20100413083931.GW2493@dastard> <190201cadaeb$02ec22c0$0400a8c0@dcccs> <20100413113445.GZ2493@dastard> <1cd501cadb62$3a93e790$0400a8c0@dcccs> <20100414001615.GC2493@dastard> <233401cadc69$64c1f4f0$0400a8c0@dcccs> <20100415092330.GU2493@dastard>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look please!...)
Date: Fri, 16 Apr 2010 10:01:10 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>


----- Original Message ----- 
From: "Dave Chinner" <david@fromorbit.com>
To: "Janos Haar" <janos.haar@netcenter.hu>
Cc: <xiyou.wangcong@gmail.com>; <linux-kernel@vger.kernel.org>; 
<kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>; <xfs@oss.sgi.com>; 
<axboe@kernel.dk>
Sent: Thursday, April 15, 2010 11:23 AM
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look 
please!...)


> On Thu, Apr 15, 2010 at 09:00:49AM +0200, Janos Haar wrote:
>> Dave,
>>
>> The corruption + crash reproduced. (unfortunately)
>>
>> http://download.netcenter.hu/bughunt/20100413/messages-15
>>
>> Apr 14 01:06:33 alfa kernel: XFS mounting filesystem sdb2
>>
>> This was the point of the xfs_repair more times.
>
> OK, the inodes that are corrupted are different, so there's still
> something funky going on here. I still would suggest replacing the
> RAID controller to rule that out as the cause.

News:

(reminder from the actual state:
xfs_repair fixed the fs, than kernel reported again the corruption and 
crashed, i wrote the provious letter to report this.)

Yesterday i have stopped the service, and run xfs_repair (new version only) 
on 2 FS, but it was clean!
(this shows me, the reported corruption was only in memory, or the kernel 
repaired it on the reboot.)
(The XFS_Debug turned on before.)
Today morning i have another messages in the syslog from the sdb2 again.
At this point, i don't know what to think.

http://download.netcenter.hu/bughunt/20100413/messages-16

Regards,
Janos


>
> FWIW, do you have any other servers with similar h/w, s/w and
> workloads? If so, are they seeing problems?
>
> Can you recompile the kernel with CONFIG_XFS_DEBUG enabled and
> reboot into it before you repair and remount the filesystem again?
> (i.e. so that we know that we have started with a clean filesystem
> and the debug kernel) I'm hoping that this will catch the corruption
> much sooner, perhaps before it gets to disk. Note that this will
> cause the machine to panic when corruption is detected, and it is
> much,much more careful about checking in memory structures so there
> is a CPU overhead involved as well.
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
