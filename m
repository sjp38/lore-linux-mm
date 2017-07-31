Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB3B6B05CD
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 03:43:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v31so45604291wrc.7
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 00:43:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e29si25556238wrc.308.2017.07.31.00.43.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 00:43:53 -0700 (PDT)
Date: Mon, 31 Jul 2017 09:43:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: don't zero ballooned pages
Message-ID: <20170731074350.GC15767@dhcp22.suse.cz>
References: <1501474413-21580-1-git-send-email-wei.w.wang@intel.com>
 <20170731065508.GE13036@dhcp22.suse.cz>
 <597EDF3D.8020101@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <597EDF3D.8020101@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, mawilcox@microsoft.com, dave.hansen@intel.com, akpm@linux-foundation.org, zhenwei.pi@youruncloud.com

On Mon 31-07-17 15:41:49, Wei Wang wrote:
> On 07/31/2017 02:55 PM, Michal Hocko wrote:
> >On Mon 31-07-17 12:13:33, Wei Wang wrote:
> >>Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
> >>shouldn't be given to the host ksmd to scan.
> >Could you point me where this MADV_DONTNEED is done, please?
> 
> Sure. It's done in the hypervisor when the balloon pages are received.
> 
> Please see line 40 at
> https://github.com/qemu/qemu/blob/master/hw/virtio/virtio-balloon.c

Thanks. Are all hypervisors which are using this API doing this?
bb01b64cfab7 doesn't mention the specify hypervisor nor does it mention
any real numbers so I suspect the revert is the right thing to do but
the changelog should mention all those details.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
