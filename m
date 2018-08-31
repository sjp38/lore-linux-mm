Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 615BE6B58E5
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 16:50:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z23-v6so4240798wma.2
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 13:50:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z78-v6sor6741677wrb.45.2018.08.31.13.50.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 13:50:41 -0700 (PDT)
Date: Fri, 31 Aug 2018 22:50:40 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC v2 2/2] mm/memory_hotplug: Shrink spanned pages when
 offlining memory
Message-ID: <20180831205040.GA3945@techadventures.net>
References: <20180817154127.28602-1-osalvador@techadventures.net>
 <20180817154127.28602-3-osalvador@techadventures.net>
 <348c662b-455a-1ea4-1db5-3bddcbdb4f14@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <348c662b-455a-1ea4-1db5-3bddcbdb4f14@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "david@redhat.com" <david@redhat.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "logang@deltatee.com" <logang@deltatee.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On Wed, Aug 29, 2018 at 11:09:01PM +0000, Pasha Tatashin wrote:
> Hi Oscar,
> 
> I have been studying this patch, and do not see anything bad about it
> except that it begs to be split into smaller patches. I think you can
> send this work as a series without RFC if this patch is split into 3 or
> so patches. I will review that series.

Thanks Pavel for having taken a look at this.
I will split up the patch and re-send it without RFC.

Thanks!
-- 
Oscar Salvador
SUSE L3
