Date: Thu, 13 Sep 2007 19:35:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: problem with ZONE_MOVABLE.
Message-Id: <20070913193547.acc8879b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46E9112E.5020505@linux.vnet.ibm.com>
References: <20070913190719.ab6451e7.kamezawa.hiroyu@jp.fujitsu.com>
	<46E9112E.5020505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.osdl.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007 16:00:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Mel, has sent out a fix (for the single zonelist) that conflicts with
> this one. Your fix looks correct to me, but it will be over ridden
> by Mel's fix (once those patches are in -mm).
> 
Ah yes. just for notification.

thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
