Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD3568D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 21:49:07 -0500 (EST)
Message-ID: <4D55F4B6.8040801@oracle.com>
Date: Fri, 11 Feb 2011 18:47:18 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: mmotm 2011-02-10-16-26 uploaded (zcache')
References: <201102110100.p1B10sDx029244@imap1.linux-foundation.org 53491.1297461155@localhost> <b4feb995-1e73-4c12-8c58-ad0c2252233c@default>
In-Reply-To: <b4feb995-1e73-4c12-8c58-ad0c2252233c@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>

On 2/11/2011 2:09 PM, Dan Magenheimer wrote:
>> From: Valdis.Kletnieks@vt.edu [mailto:Valdis.Kletnieks@vt.edu]
>> Sent: Friday, February 11, 2011 2:53 PM
>> To: akpm@linux-foundation.org; Dan Magenheimer
>> Cc: mm-commits@vger.kernel.org; linux-kernel@vger.kernel.org; linux-
>> mm@kvack.org; linux-fsdevel@vger.kernel.org
>> Subject: Re: mmotm 2011-02-10-16-26 uploaded
>>
>> On Thu, 10 Feb 2011 16:26:36 PST, akpm@linux-foundation.org said:
>>> The mm-of-the-moment snapshot 2011-02-10-16-26 has been uploaded to
>>>
>>>     http://userweb.kernel.org/~akpm/mmotm/
>>
>> CONFIG_ZCACHE=m dies a horrid death:
>
> Thanks Valdis.  A fix for this has already been posted by
> Nitin Gupta and Randy Dunlap here:
>
> https://lkml.org/lkml/2011/2/10/383
>
> Another patch for a zcache memory leak has been posted here:
>
> https://lkml.org/lkml/2011/2/10/306
>
> I'm sorry that multiple people have run into this in
> multiple trees.
> I have to admit I am a bit baffled as to what the proper
> tree flow is for bug fixes like this, but would be happy
> to "follow the process" if I am told what it is or if
> someone can point me to a document describing it.
>
> (Clearly making sure there are no bugs at all in a
> submission is the best way to go, but I'm afraid
> I can't claim to be perfect :-)

When CONFIG_SYSFS is not enabled:

mmotm-2011-0210-1626/drivers/staging/zcache/zcache.c:1608: error: 'ret' 
undeclared (first use in this function)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
