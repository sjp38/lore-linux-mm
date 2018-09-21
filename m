Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90BB08E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 06:31:43 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id 40-v6so12078472wrb.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 03:31:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g67-v6sor3580506wmg.18.2018.09.21.03.31.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 03:31:42 -0700 (PDT)
Date: Fri, 21 Sep 2018 12:31:41 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Avoid
 node_set/clear_state(N_HIGH_MEMORY) when !CONFIG_HIGHMEM
Message-ID: <20180921103141.GB15555@techadventures.net>
References: <20180919100819.25518-1-osalvador@techadventures.net>
 <20180919100819.25518-3-osalvador@techadventures.net>
 <e66c7d55-7145-dd6c-4b11-27893ed7a7d0@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e66c7d55-7145-dd6c-4b11-27893ed7a7d0@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "david@redhat.com" <david@redhat.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "malat@debian.org" <malat@debian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

On Thu, Sep 20, 2018 at 08:59:18PM +0000, Pasha Tatashin wrote:
> This is a rare case where I think comments are unnecessary as the code
> is self explanatory. So, I would remove the comments before:

Fair enough.
I just wanted to make clear why it was not needed.

I will remove it in the next version.

Thanks
-- 
Oscar Salvador
SUSE L3
