Date: Fri, 9 May 2008 15:25:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory hotplug: memmap_init_zone called twice.
Message-Id: <20080509152519.1b14e016.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080509060425.GA9840@osiris.boeblingen.de.ibm.com>
References: <20080509060425.GA9840@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 May 2008 08:04:25 +0200
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> Subject: [PATCH] memory hotplug: memmap_init_zone called twice.
> 
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> __add_zone calls memmap_init_zone twice if memory gets attached to
> an empty zone. Once via init_currently_empty_zone and once explictly
> right after that call.
> Looks like this is currently not a bug, however the call is
> superfluous and might lead to subtle bugs if memmap_init_zone gets
> changed. So make sure it is called only once.
> 
seems reasonable. Thank you!

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
