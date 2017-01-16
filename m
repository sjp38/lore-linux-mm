Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4BE6B0069
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 18:15:37 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f5so69525340pgi.1
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 15:15:37 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f29si10678529pga.291.2017.01.16.15.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 15:15:36 -0800 (PST)
Subject: Re: [LSF/MM ATTEND] Un-addressable device memory and block/fs
 implications
References: <20161213181511.GB2305@redhat.com>
 <87lgvgwoos.fsf@linux.vnet.ibm.com>
 <6304634e-3351-ea81-2970-506b69bc588f@linux.vnet.ibm.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <23b7763e-3fee-b93f-66aa-f6279e421194@nvidia.com>
Date: Mon, 16 Jan 2017 15:15:33 -0800
MIME-Version: 1.0
In-Reply-To: <6304634e-3351-ea81-2970-506b69bc588f@linux.vnet.ibm.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org



On 01/16/2017 04:04 AM, Anshuman Khandual wrote:
> On 12/16/2016 08:44 AM, Aneesh Kumar K.V wrote:
>> Jerome Glisse <jglisse@redhat.com> writes:
>>
>>> I would like to discuss un-addressable device memory in the context of
>>> filesystem and block device. Specificaly how to handle write-back, read,
>>> ... when a filesystem page is migrated to device memory that CPU can not
>>> access.
>>>
>>> I intend to post a patchset leveraging the same idea as the existing
>>> block bounce helper (block/bounce.c) to handle this. I believe this is
>>> worth discussing during summit see how people feels about such plan and
>>> if they have better ideas.
>>>
>>>
>>> I also like to join discussions on:
>>>   - Peer-to-Peer DMAs between PCIe devices

Yes! This is looming large, because we keep insisting on building new computers with a *lot* of GPUs 
in them, and then connect them up with NICs as well, and oddly enough, people keep trying to do 
pee-to-peer between GPUs, and from GPUs to NICs, etc. :)  It feels like the linux-rdma and linux-pci 
discussions in the past sort of stalled, due to not being certain of the long-term direction of the 
design. So it's worth coming up with that.



>>>   - CDM coherent device memory
>>>   - PMEM
>>>   - overall mm discussions
>> I would like to attend this discussion. I can talk about coherent device
>> memory and how having HMM handle that will make it easy to have one
>> interface for device driver. For Coherent device case we definitely need
>> page cache migration support.
>
> I have been in the discussion on the mailing list about HMM since V13 which
> got posted back in October. Touched upon many points including how it changes
> ZONE_DEVICE to accommodate un-addressable device memory, migration capability
> of currently supported ZONE_DEVICE based persistent memory etc. Looked at the
> HMM more closely from the perspective whether it can also accommodate coherent
> device memory which has been already discussed by others on this thread. I too
> would like to attend to discuss more on this topic.

Also, on the huge page points (mentioned early in this short thread): some of our GPUs could, at 
times, match the CPU's large/huge page sizes. It is a delicate thing to achieve, but moving around, 
say, 2 MB pages between CPU and GPU would be, for some workloads, really fast.

I should be able to present performance numbers for HMM on Pascal GPUs, so if anyone would like 
that, let me know in advance of any particular workloads or configurations that seem most 
interesting, and I'll gather that.

Also would like to attend this one.

thanks
John Hubbard
NVIDIA

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
