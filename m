Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 57AD06B000A
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:04:53 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 30 Jan 2013 11:03:35 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B102638C806D
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:03:07 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0UG37du21037238
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:03:07 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0UG36jS006134
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:03:07 -0500
Message-ID: <510943DA.4040803@linux.vnet.ibm.com>
Date: Wed, 30 Jan 2013 10:01:30 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 0/7] zswap: compressed swap caching
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359497685.16868.11.camel@joe-AO722> <510851E0.8000009@linux.vnet.ibm.com> <20130130043214.GC2580@blaptop>
In-Reply-To: <20130130043214.GC2580@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/29/2013 10:32 PM, Minchan Kim wrote:
> On Tue, Jan 29, 2013 at 04:49:04PM -0600, Seth Jennings wrote:
>> On 01/29/2013 04:14 PM, Joe Perches wrote:
>>> On Tue, 2013-01-29 at 15:40 -0600, Seth Jennings wrote:
>>>> The code required for the flushing is in a separate patch now
>>>> as requested.
>>>
>>> What tree does this apply to?
>>> Both -next and linus fail to compile.
>>
>> Link to build instruction in the cover letter:
>>
>>>> NOTE: To build, read this:
>>>> http://lkml.org/lkml/2013/1/28/586
>>
>> The complexity is due to a conflict with a zsmalloc patch in Greg's
>> staging tree that has yet to make its way upstream.
>>
>> Sorry for the inconvenience.
> 
> Seth, Please don't ignore previous review if you didn't convince reviewer.
> I don't want to consume time with arguing trivial things.
> 
> Copy and Paste from previous discussion from zsmalloc pathset
> 
>>>> On Fri, Jan 25, 2013 at 11:46:14AM -0600, Seth Jennings wrote:
>>>>> These patches are the first 4 patches of the zswap patchset I
>>>>> sent out previously.  Some recent commits to zsmalloc and
>>>>> zcache in staging-next forced a rebase. While I was at it, Nitin
>>>>> (zsmalloc maintainer) requested I break these 4 patches out from
>>>>> the zswap patchset, since they stand on their own.
>>>>
>>>> [2/4] and [4/4] is okay to merge current zsmalloc in staging but
>>>> [1/4] and [3/4] is dependent on zswap so it should be part of
>>>> zswap patchset.
>>>
>>> Just to clarify, patches 1 and 3 are _not_ dependent on zswap.  They
>>> just introduce changes that are only needed by zswap.
>>
>> I don't think so. If zswap might be not merged, we don't need [1, 3]
>> at the moment. You could argue that [1, 3] make zsmalloc more flexible
>> and I agree. BUT I want it when we have needs. It would be not too late.
>> So [1,3] should be part of zswap patchset.

I apologize.  I am really trying to keep all the feedback straight,
and I didn't know what Greg was going to do with those zsmalloc
patches.  However, as of last night, he didn't accept the two you
mentioned as being tied to zswap-only functionality.

I'll bring them back into the patchset for v5 once I/we address
Andrew's feedback, which might take some time.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
