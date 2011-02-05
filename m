Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 33A2D8D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 02:56:04 -0500 (EST)
Message-ID: <4D4D0289.2030900@tao.ma>
Date: Sat, 05 Feb 2011 15:55:53 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Writeback - current state and future
References: <20110204164222.GG4104@quack.suse.cz> <AANLkTikUwWOrz_LF1nO=y9cE=Ndt_CUMH-HwH244z6n0@mail.gmail.com>
In-Reply-To: <AANLkTikUwWOrz_LF1nO=y9cE=Ndt_CUMH-HwH244z6n0@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linuxfoundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 02/05/2011 02:06 AM, Curt Wohlgemuth wrote:
> I think it would also be valuable to include a discussion of writeback
> testing, so perhaps we can go beyond simply large numbers of dd
> processes.
>    
yeah, I guess a good test case is really needed here.
We are trying to use the new writeback, but can't find some good test 
cases that t can be used.
A good number is always needed when we prompt new kernel features to my 
employer. ;)

Regards,
Tao
> On Fri, Feb 4, 2011 at 8:42 AM, Jan Kara<jack@suse.cz>  wrote:
>    
>>   Hi,
>>
>>   I'd like to have one session about writeback. The content would highly
>> depend on the current state of things but on a general level, I'd like to
>> quickly sum up what went into the kernel (or is mostly ready to go) since
>> last LSF (handling of background writeback, livelock avoidance), what is
>> being worked on - IO-less balance_dirty_pages() (if it won't be in the
>> mostly done section), what other things need to be improved (kswapd
>> writeout, writeback_inodes_sb_if_idle() mess, come to my mind now)
>>
>>                                                                 Honza
>> --
>> Jan Kara<jack@suse.cz>
>> SUSE Labs, CR
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>      
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=ilto:"dont@kvack.org">  email@kvack.org</a>
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
