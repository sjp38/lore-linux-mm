Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC4B6B4619
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:54:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s18-v6so1139671wmh.0
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:54:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w8-v6sor444928wrn.16.2018.08.28.04.54.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 04:54:46 -0700 (PDT)
Date: Tue, 28 Aug 2018 13:54:44 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v4 3/4] mm/memory_hotplug: Define nodemask_t as a stack
 variable
Message-ID: <20180828115444.GB13859@techadventures.net>
References: <20180817090017.17610-1-osalvador@techadventures.net>
 <20180817090017.17610-4-osalvador@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180817090017.17610-4-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri, Aug 17, 2018 at 11:00:16AM +0200, Oscar Salvador wrote:
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Pavel, could you please review this?
AFAIK, the change made sense to you.

Andrew was about to take the patchset after the merge window,
but I think that a Reviewed-by would still make sense.

Thanks
-- 
Oscar Salvador
SUSE L3
