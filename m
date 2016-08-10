Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE806B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 12:29:13 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so80725713pac.3
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 09:29:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id n6si49091563pav.118.2016.08.10.09.29.12
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 09:29:12 -0700 (PDT)
Subject: Re: [RFC 11/11] mm, THP, swap: Delay splitting THP during swap out
References: <01f101d1f2da$5e943aa0$1bbcafe0$@alibaba-inc.com>
 <01f201d1f2dc$bd43f750$37cbe5f0$@alibaba-inc.com>
 <01f301d1f2dd$78df7660$6a9e6320$@alibaba-inc.com>
 <87eg5w3cpa.fsf@yhuang-mobile.sh.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <57AB5646.2000906@intel.com>
Date: Wed, 10 Aug 2016 09:28:54 -0700
MIME-Version: 1.0
In-Reply-To: <87eg5w3cpa.fsf@yhuang-mobile.sh.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org

On 08/10/2016 07:45 AM, Huang, Ying wrote:
> For vm event, I found for now there are only two vm event for swap:
> PSWPIN and PSWPOUT.  There are counted when page and read from or write
> to the block device.  So I think we have no existing vm event to count
> here.

I think the point still stands that we should ensure that we have proper
instrumentation to see when huge swap is being used and if/how pages are
being split during the process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
