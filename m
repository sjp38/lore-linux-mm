Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C9CAB6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 03:35:55 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so7567316ghr.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 00:35:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
Date: Wed, 4 Jul 2012 16:35:54 +0900
Message-ID: <CAEwNFnAHVHKtS2o=gEBSMGq8X18T_xFsK6CwxdfYtz1ne6KCQw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3 V1] mm: add new migrate type and online_movable
 for hotplug
From: Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Chris Metcalf -- <cmetcalf@tilera.com>, Len Brown -- <lenb@kernel.org>, Greg Kroah-Hartman -- <gregkh@linuxfoundation.org>, Andi Kleen -- <andi@firstfloor.org>, Julia Lawall -- <julia@diku.dk>, David Howells -- <dhowells@redhat.com>, Benjamin Herrenschmidt -- <benh@kernel.crashing.org>, Kay Sievers -- <kay.sievers@vrfy.org>, Ingo Molnar -- <mingo@elte.hu>, Paul Gortmaker -- <paul.gortmaker@windriver.com>, Daniel Kiper -- <dkiper@net-space.pl>, Andrew Morton -- <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk -- <konrad.wilk@oracle.com>, Michal Hocko -- <mhocko@suse.cz>, KAMEZAWA Hiroyuki -- <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz -- <mina86@mina86.com>, Marek Szyprowski -- <m.szyprowski@samsung.com>, Rik van Riel -- <riel@redhat.com>, Bjorn Helgaas -- <bhelgaas@google.com>, Christoph Lameter -- <cl@linux.com>, David Rientjes -- <rientjes@google.com>, linux-kernel@vger.kernel.org--, linux-acpi@vger.kernel.org--, linux-mm@kvack.org

Hello,

I am not sure when I can review this series by urgent other works.
At a glance, it seems to attract me.
But unfortunately, when I read description in cover-letter, I can't
find "What's the problem?".
If you provide that, it could help too many your Ccing people who can
judge  "whether I dive into code or not"

Thanks!

Side-Note: What's the "--" of email addresses?

On Wed, Jul 4, 2012 at 4:26 PM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
> The 1st patch fixes the allocation of CMA and prepares for movable-like types.
>
> The 2nd patch add a new migrate type which stands for the movable types which
> pages will not be changed to the other type.
>
> I chose the name MIGRATE_HOTREMOVE from MIGRATE_HOTREMOVE
> and MIGRATE_MOVABLE_STABLE, it just because the first usecase of this new type
> is for hotremove.
>
> The 3th path introduces online_movable. When a memoryblock is onlined
> by "online_movable", the kernel will not have directly reference to the page
> of the memoryblock, thus we can remove that memory any time when needed.
>
> Different from ZONE_MOVABLE: it can be used for any given memroyblock.
>
> Lai Jiangshan (3):
>   use __rmqueue_smallest when borrow memory from MIGRATE_CMA
>   add MIGRATE_HOTREMOVE type
>   add online_movable
>
>  arch/tile/mm/init.c            |    2 +-
>  drivers/acpi/acpi_memhotplug.c |    3 +-
>  drivers/base/memory.c          |   24 +++++++----
>  include/linux/memory.h         |    1 +
>  include/linux/memory_hotplug.h |    4 +-
>  include/linux/mmzone.h         |   37 +++++++++++++++++
>  include/linux/page-isolation.h |    2 +-
>  mm/compaction.c                |    6 +-
>  mm/memory-failure.c            |    8 +++-
>  mm/memory_hotplug.c            |   36 +++++++++++++---
>  mm/page_alloc.c                |   86 ++++++++++++++++-----------------------
>  mm/vmstat.c                    |    3 +
>  12 files changed, 136 insertions(+), 76 deletions(-)
>
> --
> 1.7.4.4
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
