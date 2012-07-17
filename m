Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 006A36B005D
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 04:44:49 -0400 (EDT)
Date: Tue, 17 Jul 2012 17:45:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/vmscan: remove checking on PG_lru
Message-ID: <20120717084513.GA24218@bbox>
References: <1342500254-28384-1-git-send-email-shangw@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342500254-28384-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Hello Gavin,

On Tue, Jul 17, 2012 at 12:44:14PM +0800, Gavin Shan wrote:
> Function __isolate_lru_page() is called by isolate_lru_pages() or
> isolate_migratepages_range(). For both cases, the PG_lru flag for

In isolate_lru_pages, the check is with VM_BUG_ON so if we disable
CONFIG_DEBUG_VM, we still need it.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
