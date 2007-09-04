Message-ID: <46DD2760.3040505@wldelft.nl>
Date: Tue, 04 Sep 2007 11:37:36 +0200
From: Leroy van Logchem <leroy.vanlogchem@wldelft.nl>
MIME-Version: 1.0
Subject: Re: huge improvement with per-device dirty throttling
References: <1187764638.6869.17.camel@hannibal> <p733aybzv6e.fsf@bingen.suse.de> <20070822124736.GQ13915@v2.random>
In-Reply-To: <20070822124736.GQ13915@v2.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "Jeffrey W. Baker" <jwbaker@acm.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, Aug 22, 2007 at 01:05:13PM +0200, Andi Kleen wrote:
>> Ok perhaps the new adaptive dirty limits helps your single disk
>> a lot too. But your improvements seem to be more "collateral damage" @)
>>
>> But if that was true it might be enough to just change the dirty limits
>> to get the same effect on your system. You might want to play with
>> /proc/sys/vm/dirty_*
> 
> The adaptive dirty limit is per task so it can't be reproduced with
> global sysctl. It made quite some difference when I researched into it
> in function of time. This isn't in function of time but it certainly
> makes a lot of difference too, actually it's the most important part
> of the patchset for most people, the rest is for the corner cases that
> aren't handled right currently (writing to a slow device with
> writeback cache has always been hanging the whole thing).


Self-tuning > static sysctl's. The last years we needed to use very 
small values for dirty_ratio and dirty_background_ratio to soften the 
latency problems we have during sustained writes. Imo these patches 
really help in many cases, please commit to mainline.

-- 
Leroy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
