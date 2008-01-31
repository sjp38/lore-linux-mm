Date: Thu, 31 Jan 2008 10:17:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
In-Reply-To: <1201703382.5459.3.camel@localhost>
References: <20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1201703382.5459.3.camel@localhost>
Message-Id: <20080131100838.1F3B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Lee-san

> Rik is currently out on holiday and I've been traveling.  Just getting
> back to rebasing to 24-rc8-mm1.  Thank you for your efforts in testing
> and tracking down the regressions.  I will add your fixes into my tree
> and try them out and let you know.  Rik mentioned to me that he has a
> fix for the "get_scan_ratio()" calculation that is causing us to OOM
> kill prematurely--i.e., when we still have lots of swap space to evict
> swappable anon.  I don't know if it's similar to what you have posted.
> Have to wait and see what he says.  Meantime, we'll try your patches.

thank you for your quick response.

on my test environment, my patch solve incorrect OOM.
because, too small reclaim cause OOM.

Please confirm.


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
