Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 758716B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 11:27:16 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so559352pab.12
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 08:27:16 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id rx8si29585535pac.134.2014.02.05.08.27.10
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 08:27:10 -0800 (PST)
Message-ID: <52F2665C.6040802@sr71.net>
Date: Wed, 05 Feb 2014 08:27:08 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] Kconfig: organize memory-related config options
References: <20140102202014.CA206E9B@viggo.jf.intel.com> <20140102202017.9D167747@viggo.jf.intel.com> <20140205142820.GD2425@dhcp22.suse.cz>
In-Reply-To: <20140205142820.GD2425@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/05/2014 06:28 AM, Michal Hocko wrote:
> On Thu 02-01-14 12:20:17, Dave Hansen wrote:
>> This continues in a series of patches to clean up the
>> configuration menus.  I believe they've become really hard to
>> navigate and there are some simple things we can do to make
>> things easier to find.
>>
>> This creates a "Memory Options" menu and moves some things like
>> swap and slab configuration under them.  It also moves SLUB_DEBUG
>> to the debugging menu.
>>
>> After this patch, the menu has the following options:
>>
>>   [ ] Memory placement aware NUMA scheduler
>>   [*] Enable VM event counters for /proc/vmstat
>>   [ ] Disable heap randomization
>>   [*] Support for paging of anonymous memory (swap)
>>       Choose SLAB allocator (SLUB (Unqueued Allocator))
>>   [*] SLUB per cpu partial cache
>>   [*] SLUB: attempt to use double-cmpxchg operations
> 
> Is there any reason to keep them in init/Kconfig rather than
> mm/Kconfig? It would sound like a logical place to have them all, no?

These options are the memory-related ones that fall under the "General
setup" menu and the mm/Kconfig ones fall in to "Processor type and
features".  I've been hesitant to move these over to mm/Kconfig just
because I don't want to put more stuff in the arch-specific menus.

You raise a good point, though, that there isn't a great logical
separation about what should go where.  Things like zram and KSM end up
in "Processor type and features" when they're really pretty
architecture-neutral.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
