Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CC1896B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:40:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d66so11869556wmi.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:40:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m139si5460180wma.32.2017.03.16.10.40.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 10:40:57 -0700 (PDT)
Date: Thu, 16 Mar 2017 18:40:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] rework memory hotplug onlining
Message-ID: <20170316174050.GA13654@dhcp22.suse.cz>
References: <20170315091347.GA32626@dhcp22.suse.cz>
 <1489622542.9118.8.camel@hpe.com>
 <20170316085404.GE30501@dhcp22.suse.cz>
 <1489688018.9118.14.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489688018.9118.14.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "vkuznets@redhat.com" <vkuznets@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "daniel.kiper@oracle.com" <daniel.kiper@oracle.com>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "imammedo@redhat.com" <imammedo@redhat.com>, "rientjes@google.com" <rientjes@google.com>, "mgorman@suse.de" <mgorman@suse.de>, "ak@linux.intel.com" <ak@linux.intel.com>, "slaoub@gmail.com" <slaoub@gmail.com>

On Thu 16-03-17 17:19:34, Kani, Toshimitsu wrote:
> On Thu, 2017-03-16 at 09:54 +0100, Michal Hocko wrote:
> > On Wed 15-03-17 23:08:14, Kani, Toshimitsu wrote:
> > > On Wed, 2017-03-15 at 10:13 +0100, Michal Hocko wrote:
>  :
> > > > -	zone = page_zone(pfn_to_page(valid_start));
> > > 
> > > Please do not remove the fix made in a96dfddbcc043. zone needs to
> > > be set from valid_start, not from start_pfn.
> > 
> > Thanks for pointing this out. I was scratching my head about this
> > part but was too tired from previous git archeology so I didn't check
> > the history of this particular part.
> >
> > I will restore the original behavior but before I do that I am really
> > curious whether partial memblocks are even supported for onlining.
> > Maybe I am missing something but I do not see any explicit checks for
> > NULL struct page when we set zone boundaries or online a memblock. Is
> > it possible those memblocks are just never hotplugable?
> 
> check_hotplug_memory_range() checks if a given range is aligned by the
> section size.

Ohh, right you are! I have completely missed check_hotplug_memory_range.
Thanks for pointing it out.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
