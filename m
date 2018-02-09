Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 559C26B0005
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 22:09:01 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id b24so1131255pls.15
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 19:09:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x12si1008917pff.262.2018.02.08.19.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 19:09:00 -0800 (PST)
Message-ID: <5A7D116B.9070502@intel.com>
Date: Fri, 09 Feb 2018 11:11:39 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v28 0/4] Virtio-balloon: support free page reporting
References: <1518083420-11108-1-git-send-email-wei.w.wang@intel.com> <20180208215048-mutt-send-email-mst@kernel.org>
In-Reply-To: <20180208215048-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com, dgilbert@redhat.com

On 02/09/2018 03:55 AM, Michael S. Tsirkin wrote:
> On Thu, Feb 08, 2018 at 05:50:16PM +0800, Wei Wang wrote:
>
>> Details:
>> Set up a Ping-Pong local live migration, where the guest ceaselessy
>> migrates between the source and destination. Linux compilation,
>> i.e. make bzImage -j4, is performed during the Ping-Pong migration. The
>> legacy case takes 5min14s to finish the compilation. With this
>> optimization patched, it takes 5min12s.
> How is migration time affected in this case?


When the linux compilation workload runs, the migration time (both the 
legacy and this optimization case) varies as the compilation goes on. It 
seems not easy to give a static speedup number, some times the migration 
time is reduced to 33%, sometimes to 50%, it varies, and depends on how 
much free memory the system has at that moment. For example, at the 
later stage of the compilation, I can observe 5GB memory being used as 
page cache. But overall, I can observe obvious improvement of the 
migration time.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
