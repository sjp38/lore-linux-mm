Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 548308D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:10:11 -0400 (EDT)
Message-ID: <4D7FE3BE.4000100@xmsnet.nl>
Date: Tue, 15 Mar 2011 23:10:06 +0100
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
Subject: Re: 2.6.38-rc echo 3 > /proc/sys/vm/drop_caches repairs mplayer distortions
References: <4D7E89E7.3080505@xmsnet.nl> <20110315185913.GH2140@cmpxchg.org>
In-Reply-To: <20110315185913.GH2140@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/15/2011 07:59 PM, Johannes Weiner wrote:
> linux-mm cc'd
>
> On Mon, Mar 14, 2011 at 10:34:31PM +0100, Hans de Bruin wrote:
>> Since the start of the start of 2.6.38-rc I sporadic have problems
>> with mplayer. A mpeg stream sometimes gets distorted when mplayer
>> starts. An example is at http://www.xs4all.nl/~bruinjm/mplayer.png .
>> I do not know how to trigger the behaviour, so bissecting is not
>> possible. Since yesterday however I found a way to 'repair' mplayer:
>>
>> echo 3>  /proc/sys/vm/drop_caches
>>
>> This repairs mplayer while it is running.
>
> While echo is running?  Or does one cache drop fix the problem until
> mplayer exits?  Could you describe exactly the steps you are going
> through and the effects they have?
>

mplayer either starts with a corrupt screen or not. Without interference 
  there are no switches from good to bad or the other way around. When I 
run echo 3> ... its completes in a blink of an eye and at the same time 
the mplayer screen switches from bad to good.

In an earlier snapshot I made 
(http://www.xs4all.nl/~bruinjm/earlier.png) you can see (if you ignore 
the starship) two mplayers playing the same file. The colors look the 
same. The contens on the bad window is moving horizontaly.

sometimes restarting mplayer helps, some times not. When its not the 
corrupt screens are persistent. clearing the cache between running seems 
mplayer seems to help in these cases (although I only tested this ones).

The 8mbit/s videocapture streams to have a much higher change of going 
wrong than 1mbit/s streams from other sources.

The first incident was at 26-jan the second at 7-feb. I use mplayer to 
watch the news 4 times a week. so its not failing often. At 26-jan my 
tree was at commit 6663050 (I pull and rebuild every day)

only mplayer is misbehaving. My other two favorite programs firefox and 
thunderbird work fine and I have not seen corrupt files.

-- 
Hans



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
