Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 549C06B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 06:14:00 -0500 (EST)
Message-ID: <4F5742AF.7090409@parallels.com>
Date: Wed, 7 Mar 2012 15:12:47 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, mempolicy: dummy slab_node return value for bugless
 kernels
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On 03/07/2012 08:25 AM, David Rientjes wrote:
> On Tue, 6 Mar 2012, Andrew Morton wrote:
>
>>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -1611,6 +1611,7 @@ unsigned slab_node(struct mempolicy *policy)
>>>
>>>   	default:
>>>   		BUG();
>>> +		return numa_node_id();
>>>   	}
>>>   }
>>
>> Wait.  If the above code generated a warning then surely we get a *lot*
>> of warnings!  I'd expect that a lot of code assumes that BUG() never
>> returns?
>>
>
> allyesconfig with CONFIG_BUG=n results in 50 such warnings tree wide, and
> this is the only one in mm/*.
>
>> Also, does CONIG_BUG=n even make sense?  If we got here and we know
>> that the kernel has malfunctioned, what point is there in pretending
>> otherwise?  Odd.
>>
>
> I don't suspect we'll be very popular if we try to remove it, I can see
> how it would be useful when BUG() is used when the problem isn't really
> fatal (to stop something like disk corruption), like the above case isn't.
I guess everyone that is able to track the problem back to an instance 
of BUG(), be skilled enough to be sure it is not fatal, and then 
recompile the kernel with this option (that I bet many of us didn't even 
know that existed), can very well just change it to a WARN_*, (and maybe 
patch it upstream).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
