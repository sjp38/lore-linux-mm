Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63B076B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 11:39:38 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f64-v6so27697821ioa.8
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 08:39:38 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id m11-v6si12866311ioq.144.2018.10.18.08.39.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 08:39:37 -0700 (PDT)
Date: Thu, 18 Oct 2018 16:38:36 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCH 5/5] mm/memory-hotplug: Rework
 unregister_mem_sect_under_nodes
Message-ID: <20181018163836.00005a45@huawei.com>
In-Reply-To: <20181018150221.GA31605@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
	<20181015153034.32203-6-osalvador@techadventures.net>
	<20181018152434.00001845@huawei.com>
	<20181018150221.GA31605@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>, linuxarm@huawei.com

On Thu, 18 Oct 2018 17:02:21 +0200
Oscar Salvador <osalvador@techadventures.net> wrote:

> On Thu, Oct 18, 2018 at 03:24:34PM +0100, Jonathan Cameron wrote:
> > Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>  
> 
> Thanks a lot Jonathan for having tested it!
> 
> Did you test the whole serie or only this patch?
> Since you have caught some bugs testing the memory-hotplug code
> on ARM64, I wonder if you could test it with the whole serie
> applied (if you got some free time, of course).
> 
> 
> thanks again!

Sorry I should have said.  Whole series on latest mmotm as of yesterday.
Obviously that only tested some of the code paths as I didn't test
hmm at all.

There are a few more quirks to chase down on my list, but nothing
related to this series and all superficial stuff.

I'm away from my boards (or the remote connection to them anyway) until
the 29th so any other tests will probably have to wait until then.

It's not clear if we'll take the actual arm64 support forwards but
hopefully someone will pick it up in the near future if we don't.
The complexity around pfn_valid on arm64 may take some time to unwind.

Thanks,

Jonathan
