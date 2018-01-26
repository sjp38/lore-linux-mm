Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8D76B0007
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 22:28:50 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id k6so6022743pgt.15
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 19:28:50 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e4si2433207pgn.428.2018.01.25.19.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 19:28:49 -0800 (PST)
Message-ID: <5A6AA107.3000607@intel.com>
Date: Fri, 26 Jan 2018 11:31:19 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [virtio-dev] Re: [PATCH v25 2/2] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1516871646-22741-1-git-send-email-wei.w.wang@intel.com> <1516871646-22741-3-git-send-email-wei.w.wang@intel.com> <20180125154708-mutt-send-email-mst@kernel.org> <5A6A871C.6040408@intel.com> <20180126042649-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180126042649-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On 01/26/2018 10:42 AM, Michael S. Tsirkin wrote:
> On Fri, Jan 26, 2018 at 09:40:44AM +0800, Wei Wang wrote:
>> On 01/25/2018 09:49 PM, Michael S. Tsirkin wrote:
>>> On Thu, Jan 25, 2018 at 05:14:06PM +0800, Wei Wang wrote:
>>>

>> The controversy is that the free list is not static
>> once the lock is dropped, so everything is dynamically changing, including
>> the state that was recorded. The method we are using is more prudent, IMHO.
>> How about taking the fundamental solution, and seek to improve incrementally
>> in the future?
>>
>>
>> Best,
>> Wei
> I'd like to see kicks happen outside the spinlock. kick with a spinlock
> taken looks like a scalability issue that won't be easy to
> reproduce but hurt workloads at random unexpected times.
>

Is that "kick inside the spinlock" the only concern you have? I think we 
can remove the kick actually. If we check how the host side works, it is 
worthwhile to let the host poll the virtqueue after it receives the cmd 
id from the guest (kick for cmd id isn't within the lock).


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
