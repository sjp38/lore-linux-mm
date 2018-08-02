Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B71FD6B0008
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:23:28 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n4-v6so978849pgp.8
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:23:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x37-v6si1502590pgl.544.2018.08.02.04.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:23:27 -0700 (PDT)
Message-ID: <5B62EAAC.8000505@intel.com>
Date: Thu, 02 Aug 2018 19:27:40 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com> <1532683495-31974-3-git-send-email-wei.w.wang@intel.com> <20180730090041.GC24267@dhcp22.suse.cz> <5B619599.1000307@intel.com> <20180801113444.GK16767@dhcp22.suse.cz> <5B62DDCC.3030100@intel.com> <87d7ae45-79cb-e294-7397-0e45e2af49cd@I-love.SAKURA.ne.jp>
In-Reply-To: <87d7ae45-79cb-e294-7397-0e45e2af49cd@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On 08/02/2018 07:00 PM, Tetsuo Handa wrote:
> On 2018/08/02 19:32, Wei Wang wrote:
>> On 08/01/2018 07:34 PM, Michal Hocko wrote:
>>> Do you have any numbers for how does this work in practice?
>> It works in this way: for example, we can set the parameter, balloon_pages_to_shrink,
>> to shrink 1GB memory once shrink scan is called. Now, we have a 8GB guest, and we balloon
>> out 7GB. When shrink scan is called, the balloon driver will get back 1GB memory and give
>> them back to mm, then the ballooned memory becomes 6GB.
> Since shrinker might be called concurrently (am I correct?),

Not sure about it being concurrently, but I think it would be called 
repeatedly as should_continue_reclaim() returns true.


Best,
Wei
