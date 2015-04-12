Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 42D1D6B0038
	for <linux-mm@kvack.org>; Sun, 12 Apr 2015 03:49:24 -0400 (EDT)
Received: by widdi4 with SMTP id di4so38743702wid.0
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 00:49:23 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id dn7si11451576wjb.44.2015.04.12.00.49.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Apr 2015 00:49:22 -0700 (PDT)
Received: by wiax7 with SMTP id x7so42968563wia.0
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 00:49:22 -0700 (PDT)
Message-ID: <552A237F.6060101@plexistor.com>
Date: Sun, 12 Apr 2015 10:49:19 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3 @stable] mm(v4.0): New pfn_mkwrite same as page_mkwrite
 for VM_PFNMAP
References: <55239645.9000507@plexistor.com> <55254FC4.3050206@plexistor.com> <552550A5.6040503@plexistor.com> <20150408202638.GB10865@kroah.com>
In-Reply-To: <20150408202638.GB10865@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Stable Tree <stable@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>

On 04/08/2015 11:26 PM, Greg KH wrote:
> On Wed, Apr 08, 2015 at 07:00:37PM +0300, Boaz Harrosh wrote:
>> On 04/08/2015 06:56 PM, Boaz Harrosh wrote:
>>> From: Yigal Korman <yigal@plexistor.com>
>>>
>>> [For Stable 4.0.X]
>>> The parallel patch at 4.1-rc1 to this patch is:
>>>   Subject: mm: new pfn_mkwrite same as page_mkwrite for VM_PFNMAP
>>>
>>> We need this patch for the 4.0.X stable tree if the patch
>>>   Subject: dax: use pfn_mkwrite to update c/mtime + freeze protection
>>>
>>> Was decided to be pulled into stable since it is a dependency
>>> of this patch. The file mm/memory.c was heavily changed in 4.1
>>> hence this here.
>>>
>>
>> I forgot to send this patch for the stables tree, 4.0 only.
>>
>> Again this one is only needed if we are truing to pull
>>    Subject: dax: use pfn_mkwrite to update c/mtime + freeze protection
>>
>> Which has the Stable@ tag. The problem it fixes is minor and might
>> be skipped if causes problems.
> 
> I can't take patches in the stable tree that are not in Linus's tree
> also.  Why can't I just take a corrisponding patch that is already in
> Linus's tree, why do we need something "special" here?
> 
> thanks,
> 

Hi greg

Yes sorry I did not explain very well.

the akpm tree in linux-next as two patches:
  8dca515 mm: new pfn_mkwrite same as page_mkwrite for VM_PFNMAP
  dac1bd2 dax: use pfn_mkwrite to update c/mtime + freeze protection

Now these patches will hit Linus tree in 4.1 merge window.
The second patch is tagged with stable@ CC, because it fixes DAX
which was introduced in 4.0. It depends on the 1st patch.

However the first patch is not tagged stable@ because it will not
apply at all to 4.0. This is because it patches mm/memory.c which
will completely change in 4.1. This is why I sent this special
patch which has the same exact title, and does exactly the same
as the 1st patch but on the 4.0 Kernel.

So when you encounter this 2nd patch with the Stable@ tag. I think
the best is to just ignore it, and wait for complains, which will
most probably not come because DAX is pretty experimental.
(But if we do pull it we will need this here)

> greg k-h
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
