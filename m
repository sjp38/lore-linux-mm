Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95E326B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 21:23:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b85so12262373pfj.22
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 18:23:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o69sor712562pfj.107.2017.10.20.18.23.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 18:23:07 -0700 (PDT)
Message-ID: <1508548981.5662.4.camel@gmail.com>
Subject: Re: [rfc 2/2] smaps: Show zone device memory used
From: Balbir Singh <bsingharora@gmail.com>
Date: Sat, 21 Oct 2017 12:23:01 +1100
In-Reply-To: <20171019170238.GB3044@redhat.com>
References: <20171018063123.21983-1-bsingharora@gmail.com>
	 <20171018063123.21983-2-bsingharora@gmail.com>
	 <d33c5a32-2b1a-85c7-be68-d006517b1ecd@linux.vnet.ibm.com>
	 <20171019064858.11c812e6@MiWiFi-R3-srv> <20171019170238.GB3044@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.com

On Thu, 2017-10-19 at 13:02 -0400, Jerome Glisse wrote:
> On Thu, Oct 19, 2017 at 06:48:58AM +1100, Balbir Singh wrote:
> > On Wed, 18 Oct 2017 12:40:43 +0530
> > Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:
> > 
> > > On 10/18/2017 12:01 PM, Balbir Singh wrote:
> > > > With HMM, we can have either public or private zone
> > > > device pages. With private zone device pages, they should
> > > > show up as swapped entities. For public zone device pages  
> > > 
> > > Might be missing something here but why they should show up
> > > as swapped entities ? Could you please elaborate.
> > > 
> > 
> > For migrated entries, my use case is to
> > 
> > 1. malloc()/mmap() memory
> > 2. call migrate_vma()
> > 3. Look at smaps
> > 
> > It's probably not clear in the changelog.
> 
> My only worry is about API, is smaps consider as userspace API ?

Yes, do you think choosing DevicePublicMemory would help?

> My fear here is that maybe we will want to report device memory
> differently in the future and have different category of device

You are right, things will change and we'll probably see more things
in ZONE_DEVICE, but I am not sure how they'd show up in smaps or
can't think of it at the moment. The reason for my patch is was
that I expect only device public memory to have a need to be
visible in smaps as we do migration from regular memory to device
public memory and vice-versa.

> memory. Even thought right now i can only think of wanting to
> differentiate between public and private device memory but right
> now as you pointed out this is reported as swap out.
> 
> Otherwise patches looks good and you got:
> 
> Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
