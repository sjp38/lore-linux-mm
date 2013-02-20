Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C5B276B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 16:41:50 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 20 Feb 2013 16:38:27 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 548A56EB672
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 15:39:35 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1KKdarG29949958
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 15:39:36 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1KKcD99014141
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 13:38:15 -0700
Message-ID: <5125341A.3030305@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2013 14:37:46 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 4/8] zswap: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-5-git-send-email-sjenning@linux.vnet.ibm.com> <511F0536.5030802@gmail.com> <51227FDA.7040000@linux.vnet.ibm.com> <0fb2af92-575f-4f5d-a115-829a3cf035e5@default>
In-Reply-To: <0fb2af92-575f-4f5d-a115-829a3cf035e5@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/18/2013 01:55 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCHv5 4/8] zswap: add to mm/
>>
>> On 02/15/2013 10:04 PM, Ric Mason wrote:
>>> On 02/14/2013 02:38 AM, Seth Jennings wrote:
>> <snip>
>>>> + * The statistics below are not protected from concurrent access for
>>>> + * performance reasons so they may not be a 100% accurate.  However,
>>>> + * the do provide useful information on roughly how many times a
>>>
>>> s/the/they
>>
>> Ah yes, thanks :)
>>
>>>
>>>> + * certain event is occurring.
>>>> +*/
>>>> +static u64 zswap_pool_limit_hit;
>>>> +static u64 zswap_reject_compress_poor;
>>>> +static u64 zswap_reject_zsmalloc_fail;
>>>> +static u64 zswap_reject_kmemcache_fail;
>>>> +static u64 zswap_duplicate_entry;
>>>> +
>>>> +/*********************************
>>>> +* tunables
>>>> +**********************************/
>>>> +/* Enable/disable zswap (disabled by default, fixed at boot for
>>>> now) */
>>>> +static bool zswap_enabled;
>>>> +module_param_named(enabled, zswap_enabled, bool, 0);
>>>
>>> please document in Documentation/kernel-parameters.txt.
>>
>> Will do.
> 
> Is that a good idea?  Konrad's frontswap/cleancache patches
> to fix frontswap/cleancache initialization so that backends
> can be built/loaded as modules may be merged for 3.9.
> AFAIK, module parameters are not included in kernel-parameters.txt.

Good point.  I'm looking to make zswap modular in the not too distant
future.  I'll wait on this for now.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
