Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 848946B05D7
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 04:32:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c14so350023006pgn.11
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 01:32:18 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id b62si15787659pfc.203.2017.07.31.01.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 01:32:17 -0700 (PDT)
Message-ID: <597EEBB2.8080609@intel.com>
Date: Mon, 31 Jul 2017 16:34:58 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't zero ballooned pages
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com> <20170731065508.GE13036@dhcp22.suse.cz> <597EDF3D.8020101@intel.com> <20170731074350.GC15767@dhcp22.suse.cz>
In-Reply-To: <20170731074350.GC15767@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org, zhenwei.pi@youruncloud.com

On 07/31/2017 03:43 PM, Michal Hocko wrote:
> On Mon 31-07-17 15:41:49, Wei Wang wrote:
>> On 07/31/2017 02:55 PM, Michal Hocko wrote:
>>> On Mon 31-07-17 12:13:33, Wei Wang wrote:
>>>> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
>>>> shouldn't be given to the host ksmd to scan.
>>> Could you point me where this MADV_DONTNEED is done, please?
>> Sure. It's done in the hypervisor when the balloon pages are received.
>>
>> Please see line 40 at
>> https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c
> Thanks. Are all hypervisors which are using this API doing this?


The implementation may be different across different hypervisors.
But the underlying concept is the same - they unmap the balloon
pages from the guest and those pages will be given to other guests
or host processes to use.

Regardless of the implementation, I think it is an improper operation
to make the memory KSM mergeable when the memory does not
belong to the guest anymore.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
