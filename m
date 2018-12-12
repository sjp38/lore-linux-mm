Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C08F8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 17:17:30 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so30486pfj.3
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 14:17:30 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id y73si3231pgd.478.2018.12.12.14.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 14:17:29 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <514cc9e1-dc4d-b979-c6bc-88ac503c098d@nvidia.com>
 <20181212220418.GH5037@redhat.com>
 <311cd7a7-6727-a298-964e-ad238a30bdef@nvidia.com>
 <20181212221446.GI5037@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2483bf1b-944e-ad3b-74f6-773a0aa8813c@nvidia.com>
Date: Wed, 12 Dec 2018 14:17:27 -0800
MIME-Version: 1.0
In-Reply-To: <20181212221446.GI5037@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 12/12/18 2:14 PM, Jerome Glisse wrote:
> On Wed, Dec 12, 2018 at 02:11:58PM -0800, John Hubbard wrote:
>> On 12/12/18 2:04 PM, Jerome Glisse wrote:
>>> On Wed, Dec 12, 2018 at 01:56:00PM -0800, John Hubbard wrote:
>>>> On 12/12/18 1:30 PM, Jerome Glisse wrote:
>>>>> On Wed, Dec 12, 2018 at 08:27:35AM -0800, Dan Williams wrote:
>>>>>> On Wed, Dec 12, 2018 at 7:03 AM Jerome Glisse <jglisse@redhat.com> wrote:
>>>>>>>
>>>>>>> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
>>>>>>>> On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
[...]
>>>
>>>>>     Patch 1: register mmu notifier
>>>>>     Patch 2: listen to MMU_NOTIFY_TRUNCATE and MMU_NOTIFY_UNMAP
>>>>>              when that happens update the device page table or
>>>>>              usage to point to a crappy page and do put_user_page
>>>>>              on all previously held page
>>>>
>>>> Minor point, this sequence should be done within a wrapper around existing 
>>>> get_user_pages(), such as get_user_pages_revokable() or something.
>>>
>>> No we want to teach everyone to abide by the rules, if we add yet another
>>> GUP function prototype people will use the one where they don;t have to
>>> say they abide by the rules. It is time we advertise the fact that GUP
>>> should not be use willy nilly for anything without worrying about the
>>> implication it has :)
>>
>> Well, the best way to do that is to provide a named function call that 
>> implements the rules. That also makes it easy to grep around and see which
>> call sites still need upgrades, and which don't.
>>
>>>
>>> So i would rather see a consolidation in the number of GUP prototype we
>>> have than yet another one.
>>
>> We could eventually get rid of the older GUP prototypes, once we're done
>> converting. Having a new, named function call will *without question* make
>> the call site conversion go much easier, and the end result is also better:
>> the common code is in a central function, rather than being at all the call
>> sites.
>>
> 
> Then last patch in the patchset must remove all GUP prototype except
> ones with the right API :)
> 

Yes, exactly.


thanks,
-- 
John Hubbard
NVIDIA
