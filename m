Subject: Re: [PATCH] add page->mapping handling interface [22/35] changes
	in JFFS2
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20070910191622.d18b1aaa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070910191622.d18b1aaa.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 10 Sep 2007 11:19:51 +0100
Message-Id: <1189419591.8320.161.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-10 at 19:16 +0900, KAMEZAWA Hiroyuki wrote:
> Changes page->mapping handling in JFFS2
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks reasonable to me; I assume it's not intended for me to take it and
apply it yet, before the core parts are merged? I'll let you shepherd it
upstream...

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
