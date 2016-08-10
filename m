Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59E8C6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:49:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so90137371pfd.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:49:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 190si49223543pfg.255.2016.08.10.09.49.43
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 09:49:43 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [RFC 11/11] mm, THP, swap: Delay splitting THP during swap out
References: <01f101d1f2da$5e943aa0$1bbcafe0$@alibaba-inc.com>
	<01f201d1f2dc$bd43f750$37cbe5f0$@alibaba-inc.com>
	<01f301d1f2dd$78df7660$6a9e6320$@alibaba-inc.com>
	<87eg5w3cpa.fsf@yhuang-mobile.sh.intel.com>
	<57AB5646.2000906@intel.com>
Date: Wed, 10 Aug 2016 09:49:40 -0700
In-Reply-To: <57AB5646.2000906@intel.com> (Dave Hansen's message of "Wed, 10
	Aug 2016 09:28:54 -0700")
Message-ID: <87mvkk1sd7.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org

Dave Hansen <dave.hansen@intel.com> writes:

> On 08/10/2016 07:45 AM, Huang, Ying wrote:
>> For vm event, I found for now there are only two vm event for swap:
>> PSWPIN and PSWPOUT.  There are counted when page and read from or write
>> to the block device.  So I think we have no existing vm event to count
>> here.
>
> I think the point still stands that we should ensure that we have proper
> instrumentation to see when huge swap is being used and if/how pages are
> being split during the process.

Sounds reasonable to me.  I think we can count the event that a huge
swap entry is allocated and put into swap cache successfully, say
THP_SWPCACHE.  I am not good at naming, so feel free to suggest a better
name.

And this patchset is just the first step of THP swap support.  In the
near future, the THP splitting during swapping out could be further
delayed after writing the THP to the block device.  At that time, we
will have a THP_SWPOUT vm event for THP swapping out.  Then the
THP_SWPCACHE event may appear unnecessary?  If so, we add the event now
and remove it at that time?

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
