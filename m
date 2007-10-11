Date: Thu, 11 Oct 2007 21:54:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [5/5] ---
 fix page migration under memory controller
Message-Id: <20071011215413.c3a27633.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <470E1194.6060001@linux.vnet.ibm.com>
References: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
	<20071011140220.a62daf1a.kamezawa.hiroyu@jp.fujitsu.com>
	<470E1194.6060001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Oct 2007 17:35:40 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > +
> > +static inline void
> > +mem_cgroup_page_migration(struct page *page, struct page *newpage);
> 
> Typo, the semicolon needs to go :-)
>
Oh, thanks!, will send updated version later.

-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
