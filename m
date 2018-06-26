Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E2A0D6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 08:23:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a12-v6so8638767pfn.12
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 05:23:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 91-v6si1449559ple.308.2018.06.26.05.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 05:23:46 -0700 (PDT)
Message-ID: <5B323140.1000306@intel.com>
Date: Tue, 26 Jun 2018 20:27:44 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v34 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com> <1529928312-30500-3-git-send-email-wei.w.wang@intel.com> <20180626002822-mutt-send-email-mst@kernel.org> <5B31B71B.6080709@intel.com> <20180626064338-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180626064338-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On 06/26/2018 11:56 AM, Michael S. Tsirkin wrote:
> On Tue, Jun 26, 2018 at 11:46:35AM +0800, Wei Wang wrote:
>

>>
>>>
>>>> +	if (!arrays)
>>>> +		return NULL;
>>>> +
>>>> +	for (i = 0; i < max_array_num; i++) {
>>> So we are getting a ton of memory here just to free it up a bit later.
>>> Why doesn't get_from_free_page_list get the pages from free list for us?
>>> We could also avoid the 1st allocation then - just build a list
>>> of these.
>> That wouldn't be a good choice for us. If we check how the regular
>> allocation works, there are many many things we need to consider when pages
>> are allocated to users.
>> For example, we need to take care of the nr_free
>> counter, we need to check the watermark and perform the related actions.
>> Also the folks working on arch_alloc_page to monitor page allocation
>> activities would get a surprise..if page allocation is allowed to work in
>> this way.
>>
> mm/ code is well positioned to handle all this correctly.

I'm afraid that would be a re-implementation of the alloc functions, and 
that would be much more complex than what we have. I think your idea of 
passing a list of pages is better.

Best,
Wei
