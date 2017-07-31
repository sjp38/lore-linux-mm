Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AEDE6B05C7
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 03:39:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so276029268pgy.1
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 00:39:09 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y94si8101625plh.881.2017.07.31.00.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 00:39:08 -0700 (PDT)
Message-ID: <597EDF3D.8020101@intel.com>
Date: Mon, 31 Jul 2017 15:41:49 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: don't zero ballooned pages
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com> <20170731065508.GE13036@dhcp22.suse.cz>
In-Reply-To: <20170731065508.GE13036@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org, zhenwei.pi@youruncloud.com

On 07/31/2017 02:55 PM, Michal Hocko wrote:
> On Mon 31-07-17 12:13:33, Wei Wang wrote:
>> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
>> shouldn't be given to the host ksmd to scan.
> Could you point me where this MADV_DONTNEED is done, please?

Sure. It's done in the hypervisor when the balloon pages are received.

Please see line 40 at
https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c


>
>> Therefore, it is not
>> necessary to zero ballooned pages, which is very time consuming when
>> the page amount is large. The ongoing fast balloon tests show that the
>> time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
>> __GFP_ZERO added. So, this patch removes the flag.
> Please make it obvious that this is a revert of bb01b64cfab7
> ("mm/balloon_compaction.c: enqueue zero page to balloon device").
>
>

Ok, will do.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
