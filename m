Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B68AA8D0015
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 01:51:09 -0400 (EDT)
Date: Mon, 25 Oct 2010 13:51:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] do_migrate_range: exit loop if not_managed is true.
Message-ID: <20101025055101.GA24406@localhost>
References: <1287667701-8081-1-git-send-email-lliubbo@gmail.com>
 <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1287667701-8081-2-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2010 at 09:28:20PM +0800, Bob Liu wrote:
> If not_managed is true all pages will be putback to lru, so
> break the loop earlier to skip other pages isolate.
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
