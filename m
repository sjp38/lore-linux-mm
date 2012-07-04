Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C71AB6B006C
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 10:58:41 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so8084238ghr.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 07:58:40 -0700 (PDT)
Date: Wed, 4 Jul 2012 07:58:35 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH 3/3 V1] mm, memory-hotplug: add online_movable
Message-ID: <20120704145835.GA23273@kroah.com>
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
 <1341386778-8002-4-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341386778-8002-4-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Chris Metcalf <cmetcalf@tilera.com>, --@kroah.com, Len Brown <lenb@kernel.org>, Andi Kleen <andi@firstfloor.org>, Julia Lawall <julia@diku.dk>, David Howells <dhowells@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kay Sievers <kay.sievers@vrfy.org>, Ingo Molnar <mingo@elte.hu>, Paul Gortmaker <paul.gortmaker@windriver.com>, Daniel Kiper <dkiper@net-space.pl>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org--, linux-acpi@vger.kernel.org--, linux-mm@kvack.org

On Wed, Jul 04, 2012 at 03:26:18PM +0800, Lai Jiangshan wrote:
> When a memoryblock is onlined by "online_movable", the kernel will not
> have directly reference to the page of the memoryblock,
> thus we can remove that memory any time when needed.
> 
> It makes things easy when we dynamic hot-add/remove memory, make better
> utilities of memories.

As you are changing the kernel/user API here, please update
Documentation/ABI with the proper sysfs file changes at the same time.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
