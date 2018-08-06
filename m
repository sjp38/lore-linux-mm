Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2126B0266
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 05:53:28 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id bb5-v6so2023791plb.13
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 02:53:28 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b2-v6si10588093pge.114.2018.08.06.02.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 02:53:27 -0700 (PDT)
Message-ID: <5B681B41.6070205@intel.com>
Date: Mon, 06 Aug 2018 17:56:17 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com> <1533285146-25212-3-git-send-email-wei.w.wang@intel.com> <16c56ee5-eef7-dd5f-f2b6-e3c11df2765c@i-love.sakura.ne.jp>
In-Reply-To: <16c56ee5-eef7-dd5f-f2b6-e3c11df2765c@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org

On 08/03/2018 08:11 PM, Tetsuo Handa wrote:
> On 2018/08/03 17:32, Wei Wang wrote:
>> +static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
>> +{
>> +	vb->shrinker.scan_objects = virtio_balloon_shrinker_scan;
>> +	vb->shrinker.count_objects = virtio_balloon_shrinker_count;
>> +	vb->shrinker.batch = 0;
>> +	vb->shrinker.seeks = DEFAULT_SEEKS;
> Why flags field is not set? If vb is allocated by kmalloc(GFP_KERNEL)
> and is nowhere zero-cleared, KASAN would complain it.

Could you point where in the code that would complain it?
I only see two shrinker flags (NUMA_AWARE and MEMCG_AWARE), and they 
seem not related to that.


Best,
Wei
