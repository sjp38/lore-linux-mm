Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 3275D6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 06:49:55 -0400 (EDT)
Message-ID: <4FF41FF2.1010600@cn.fujitsu.com>
Date: Wed, 04 Jul 2012 18:50:26 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/3 V1] mm, page migrate: add MIGRATE_HOTREMOVE type
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com> <1341386778-8002-3-git-send-email-laijs@cn.fujitsu.com> <20120704101942.GM13141@csn.ul.ie>
In-Reply-To: <20120704101942.GM13141@csn.ul.ie>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <andi@firstfloor.org>, Julia Lawall <julia@diku.dk>, David Howells <dhowells@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kay Sievers <kay.sievers@vrfy.org>, Ingo Molnar <mingo@elte.hu>, Paul Gortmaker <paul.gortmaker@windriver.com>, Daniel Kiper <dkiper@net-space.pl>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On 07/04/2012 06:19 PM, Mel Gorman wrote:
> On Wed, Jul 04, 2012 at 03:26:17PM +0800, Lai Jiangshan wrote:
>> MIGRATE_HOTREMOVE is a special kind of MIGRATE_MOVABLE, but it is stable:
>> any page of the type can NOT be changed to the other type nor be moved to
>> the other free list.
>>
>> So the pages of MIGRATE_HOTREMOVE are always movable, this ability is
>> useful for hugepages and hotremove ...etc.
>>
>> MIGRATE_HOTREMOVE pages is the used as the first candidate when
>> we allocate movable pages.
>>
>> 1) add small routine is_migrate_movable() for movable-like types
>> 2) add small routine is_migrate_stable() for stable types
>> 3) fix some comments
>> 4) fix get_any_page(). The get_any_page() may change
>>    MIGRATE_CMA/HOTREMOVE types page to MOVABLE which may cause this page
>>    to be changed to UNMOVABLE.
>>
> 
> Reuse MIGRATE_CMA. 

Will do it.

> Even if the pages are on the movable lists it should
> not be a problem for memory hot-remove.

It does have problem, unmovable pages may be allocated on it.

The movable lists can be used for other type when ohter type is empty.
Or we can rename current movable-lists to movable-preference-lists.

Thanks,
Lai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
