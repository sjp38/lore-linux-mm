Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD766B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:29:33 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p14-v6so11661367oip.0
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:29:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n125-v6si8412590oih.331.2018.08.06.03.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:29:32 -0700 (PDT)
Subject: Re: [PATCH v3 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com>
 <1533285146-25212-3-git-send-email-wei.w.wang@intel.com>
 <16c56ee5-eef7-dd5f-f2b6-e3c11df2765c@i-love.sakura.ne.jp>
 <5B681B41.6070205@intel.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c8d25019-1990-f0dd-c83d-e4def5b5f7fe@i-love.sakura.ne.jp>
Date: Mon, 6 Aug 2018 19:29:17 +0900
MIME-Version: 1.0
In-Reply-To: <5B681B41.6070205@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org

On 2018/08/06 18:56, Wei Wang wrote:
> On 08/03/2018 08:11 PM, Tetsuo Handa wrote:
>> On 2018/08/03 17:32, Wei Wang wrote:
>>> +static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
>>> +{
>>> +A A A  vb->shrinker.scan_objects = virtio_balloon_shrinker_scan;
>>> +A A A  vb->shrinker.count_objects = virtio_balloon_shrinker_count;
>>> +A A A  vb->shrinker.batch = 0;
>>> +A A A  vb->shrinker.seeks = DEFAULT_SEEKS;
>> Why flags field is not set? If vb is allocated by kmalloc(GFP_KERNEL)
>> and is nowhere zero-cleared, KASAN would complain it.
> 
> Could you point where in the code that would complain it?
> I only see two shrinker flags (NUMA_AWARE and MEMCG_AWARE), and they seem not related to that.

Where is vb->shrinker.flags initialized?
