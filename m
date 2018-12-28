Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB31C8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:06:49 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o17so18994554pgi.14
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:06:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p14si35560560plq.25.2018.12.27.19.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 19:06:48 -0800 (PST)
Message-ID: <5C259485.2030809@intel.com>
Date: Fri, 28 Dec 2018 11:12:05 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v37 1/3] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
References: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com> <1535333539-32420-2-git-send-email-wei.w.wang@intel.com> <49d706f7-a0ee-e571-7d02-bcadac5ce742@de.ibm.com>
In-Reply-To: <49d706f7-a0ee-e571-7d02-bcadac5ce742@de.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, dgilbert@redhat.com
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, quintela@redhat.com, Cornelia Huck <cohuck@redhat.com>, Halil Pasic <pasic@linux.ibm.com>

On 12/27/2018 08:03 PM, Christian Borntraeger wrote:
> On 27.08.2018 03:32, Wei Wang wrote:
>>   static int init_vqs(struct virtio_balloon *vb)
>>   {
>> -	struct virtqueue *vqs[3];
>> -	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
>> -	static const char * const names[] = { "inflate", "deflate", "stats" };
>> -	int err, nvqs;
>> +	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
>> +	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
>> +	const char *names[VIRTIO_BALLOON_VQ_MAX];
>> +	int err;
>>
>>   	/*
>> -	 * We expect two virtqueues: inflate and deflate, and
>> -	 * optionally stat.
>> +	 * Inflateq and deflateq are used unconditionally. The names[]
>> +	 * will be NULL if the related feature is not enabled, which will
>> +	 * cause no allocation for the corresponding virtqueue in find_vqs.
>>   	 */
> This might be true for virtio-pci, but it is not for virtio-ccw.

Hi Christian,


Please try the fix patches: https://lkml.org/lkml/2018/12/27/336

Best,
Wei
