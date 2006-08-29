Date: Tue, 29 Aug 2006 14:41:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] call mm/page-writeback.c:set_ratelimit() when new pages
 are hot-added
Message-Id: <20060829144134.b01ac28f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1156803805.1196.74.camel@linuxchandra>
References: <1156803805.1196.74.camel@linuxchandra>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: akpm@osdl.org, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 28 Aug 2006 15:23:25 -0700
Chandra Seetharaman <sekharan@us.ibm.com> wrote:

> ratelimit_pages in page-writeback.c is recalculated (in set_ratelimit())
> every time a CPU is hot-added/removed. But this value is not recalculated
> when new pages are hot-added.
> 
> This patch fixes that problem by calling set_ratelimit() when new pages
> are hot-added.
> 

Hi, 
How about adding memory hotplug notifier callbacks (like cpu hotplug) ?
I'll try it if it's worth adding.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
