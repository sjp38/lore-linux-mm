From: Yohan <kernel@yohan.staff.proxad.net>
Subject: Re: VM issue causing high CPU loads
Date: Wed, 26 Aug 2009 13:55:34 +0200
Message-ID: <4A9522B6.7060607@yohan.staff.proxad.net>
References: <4A92A25A.4050608@yohan.staff.proxad.net> <20090824162155.ce323f08.akpm@linux-foundation.org> <20090826110809.GG10955@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756879AbZHZLzh@vger.kernel.org>
In-Reply-To: <20090826110809.GG10955@csn.ul.ie>
Sender: linux-kernel-owner@vger.kernel.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Mel Gorman wrote:
> On Mon, Aug 24, 2009 at 04:21:55PM -0700, Andrew Morton wrote:
>   
>> On Mon, 24 Aug 2009 16:23:22 +0200
>> Yohan <kernel@yohan.staff.proxad.net> wrote:
>>     
>>> Hi,
>>>
>>>     Is someone have an idea for that :
>>>
>>>         http://bugzilla.kernel.org/show_bug.cgi?id=14024
>>>       
>> Please generate a kernel profile to work out where all the CPU tie is
>> being spent.  Documentation/basic_profiling.txt is a starting point.
>>     
> In the absense of a profile, here is a total stab in the dark. Is this a
> NUMA machine? 
This is a Intel(R) Xeon(R) CPU E5520 on Dell R610
> If so, is /proc/sys/vm/zone_reclaim_mode set to 1 and does
> setting it to 0 help?
>   
The value is already 0...


Thanks
