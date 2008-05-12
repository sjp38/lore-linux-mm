Date: Mon, 12 May 2008 18:19:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory_hotplug: always initialize pageblock bitmap.
Message-Id: <20080512181928.cd41c055.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080512105500.ff89c0d3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080509060609.GB9840@osiris.boeblingen.de.ibm.com>
	<20080509153910.6b074a30.kamezawa.hiroyu@jp.fujitsu.com>
	<20080510124501.GA4796@osiris.boeblingen.de.ibm.com>
	<20080512105500.ff89c0d3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 12 May 2008 10:55:00 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> seems good. I'll try this logic on my ia64 box, which allows
> NUMA-node hotplug.
> 
I'm sorry but I found memory-hotplug on my box doesn't work now
maybe because of recent? changes in linux's ACPI. It seems no notifies
reach to acpi container/memory driver. (maybe another regression...)
I'll dig...but it may take some amount of time.

I have no objection to your patch as a result of review.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
