Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 248186B0035
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 10:08:51 -0400 (EDT)
Received: by mail-ob0-f177.google.com with SMTP id wp18so10297758obc.22
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 07:08:50 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id qd10si46288112oeb.5.2014.08.25.07.08.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Aug 2014 07:08:50 -0700 (PDT)
Message-ID: <1408975109.28990.98.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] memory-hotplug: add sysfs zones_online_to attribute
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 25 Aug 2014 07:58:29 -0600
In-Reply-To: <20140822151622.6786c1089548ea5ceb3732bf@linux-foundation.org>
References: <1407902811-4873-1-git-send-email-zhenzhang.zhang@huawei.com>
	 <53EAE534.8030303@huawei.com> <1408138647.26567.42.camel@misato.fc.hp.com>
	 <53F17230.5020409@huawei.com>
	 <20140822151622.6786c1089548ea5ceb3732bf@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Zhen <zhenzhang.zhang@huawei.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com, n-horiguchi@ah.jp.nec.com, wangnan0@huawei.com, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Fri, 2014-08-22 at 15:16 -0700, Andrew Morton wrote:
> On Mon, 18 Aug 2014 11:25:36 +0800 Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:
> 
> > On 2014/8/16 5:37, Toshi Kani wrote:
> > > On Wed, 2014-08-13 at 12:10 +0800, Zhang Zhen wrote:
> > >> Currently memory-hotplug has two limits:
> > >> 1. If the memory block is in ZONE_NORMAL, you can change it to
> > >> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
> > >> 2. If the memory block is in ZONE_MOVABLE, you can change it to
> > >> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
> > >>
> > >> With this patch, we can easy to know a memory block can be onlined to
> > >> which zone, and don't need to know the above two limits.
> > >>
> > >> Updated the related Documentation.
> > >>
> > >> Change v1 -> v2:
> > >> - optimize the implementation following Dave Hansen's suggestion
> > >>
> > >> Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
> > >> ---
> > >>  Documentation/ABI/testing/sysfs-devices-memory |  8 ++++
> > >>  Documentation/memory-hotplug.txt               |  4 +-
> > >>  drivers/base/memory.c                          | 62 ++++++++++++++++++++++++++
> > >>  include/linux/memory_hotplug.h                 |  1 +
> > >>  mm/memory_hotplug.c                            |  2 +-
> > >>  5 files changed, 75 insertions(+), 2 deletions(-)
> > >>
> > >> diff --git a/Documentation/ABI/testing/sysfs-devices-memory b/Documentation/ABI/testing/sysfs-devices-memory
> > >> index 7405de2..2b2a1d7 100644
> > >> --- a/Documentation/ABI/testing/sysfs-devices-memory
> > >> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> > >> @@ -61,6 +61,14 @@ Users:		hotplug memory remove tools
> > >>  		http://www.ibm.com/developerworks/wikis/display/LinuxP/powerpc-utils
> > >>
> > >>
> > >> +What:           /sys/devices/system/memory/memoryX/zones_online_to
> > > 
> > > I think this name is a bit confusing.  How about "valid_online_types"?
> > > 
> > Thanks for your suggestion.
> > 
> > This patch has been added to -mm tree.
> > If most people think so, i would like to modify the interface name.
> > If not, let's leave it as it is.
> 
> Yes, the name could be better.  Do we actually need "online" in there? 
> How about "valid_zones"?

I suggested using "online" because a user specifies a zone type during
an online operation as follows.

  $ echo online_movable > /sys/devices/system/memory/memoryXXX/state

I also like "valid_zones" and it well represents what it is (and the
name is shorter :-).  I am fine with this name as well.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
