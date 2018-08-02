Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AF196B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:00:48 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e23-v6so1545926oii.10
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:00:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t71-v6si1034081oie.247.2018.08.02.04.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:00:47 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
 <1532683495-31974-3-git-send-email-wei.w.wang@intel.com>
 <20180730090041.GC24267@dhcp22.suse.cz> <5B619599.1000307@intel.com>
 <20180801113444.GK16767@dhcp22.suse.cz> <5B62DDCC.3030100@intel.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <87d7ae45-79cb-e294-7397-0e45e2af49cd@I-love.SAKURA.ne.jp>
Date: Thu, 2 Aug 2018 20:00:32 +0900
MIME-Version: 1.0
In-Reply-To: <5B62DDCC.3030100@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On 2018/08/02 19:32, Wei Wang wrote:
> On 08/01/2018 07:34 PM, Michal Hocko wrote:
>> Do you have any numbers for how does this work in practice?
> 
> It works in this way: for example, we can set the parameter, balloon_pages_to_shrink,
> to shrink 1GB memory once shrink scan is called. Now, we have a 8GB guest, and we balloon
> out 7GB. When shrink scan is called, the balloon driver will get back 1GB memory and give
> them back to mm, then the ballooned memory becomes 6GB.

Since shrinker might be called concurrently (am I correct?), the balloon might deflate
far more than needed if it releases such much memory. If shrinker is used, releasing 256
pages might be sufficient.
