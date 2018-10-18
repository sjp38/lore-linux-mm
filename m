Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDB96B000C
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 11:02:25 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j13-v6so24221277wre.6
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 08:02:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j17-v6sor13197300wrn.8.2018.10.18.08.02.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 08:02:23 -0700 (PDT)
Date: Thu, 18 Oct 2018 17:02:21 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH 5/5] mm/memory-hotplug: Rework
 unregister_mem_sect_under_nodes
Message-ID: <20181018150221.GA31605@techadventures.net>
References: <20181015153034.32203-1-osalvador@techadventures.net>
 <20181015153034.32203-6-osalvador@techadventures.net>
 <20181018152434.00001845@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018152434.00001845@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, yasu.isimatu@gmail.com, rppt@linux.vnet.ibm.com, malat@debian.org, linux-kernel@vger.kernel.org, pavel.tatashin@microsoft.com, jglisse@redhat.com, rafael@kernel.org, david@redhat.com, dave.jiang@intel.com, linux-mm@kvack.org, alexander.h.duyck@linux.intel.com, Oscar Salvador <osalvador@suse.de>, linuxarm@huawei.com

On Thu, Oct 18, 2018 at 03:24:34PM +0100, Jonathan Cameron wrote:
> Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Thanks a lot Jonathan for having tested it!

Did you test the whole serie or only this patch?
Since you have caught some bugs testing the memory-hotplug code
on ARM64, I wonder if you could test it with the whole serie
applied (if you got some free time, of course).


thanks again!
-- 
Oscar Salvador
SUSE L3
