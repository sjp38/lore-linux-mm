Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 640196B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 12:18:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p111so3504487wrc.10
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 09:18:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p191si8802376wmd.27.2017.04.12.09.18.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 09:18:40 -0700 (PDT)
Date: Wed, 12 Apr 2017 09:18:29 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170412161829.GA16422@linux-80c1.suse>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
 <20170328175408.GD7838@bombadil.infradead.org>
 <20170329080625.GC27994@dhcp22.suse.cz>
 <20170329174514.GB4543@tassilo.jf.intel.com>
 <20170330061245.GA1972@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170330061245.GA1972@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Thu, 30 Mar 2017, Michal Hocko wrote:

>On Wed 29-03-17 10:45:14, Andi Kleen wrote:
>> On Wed, Mar 29, 2017 at 10:06:25AM +0200, Michal Hocko wrote:
>> >
>> > Do we actually have any users?
>>
>> Yes this feature is widely used.
>
>Considering that none of SHM_HUGE* has been exported to the userspace
>headers all the users would have to use the this flag by the value and I
>am quite skeptical that application actually do that. Could you point me
>to some projects that use this?

Hmm Andrew, if there's not one example, could you please pick up this patch?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
