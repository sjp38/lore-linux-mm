Date: Thu, 28 Feb 2008 17:27:39 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 21/21] cull non-reclaimable anon pages from the LRU at
 fault time
Message-ID: <20080228172739.61fc3780@bree.surriel.com>
In-Reply-To: <1204229973.5301.34.camel@localhost>
References: <20080228192908.126720629@redhat.com>
	<20080228192929.793021800@redhat.com>
	<1204229973.5301.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008 15:19:33 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Thu, 2008-02-28 at 14:29 -0500, Rik van Riel wrote:
> 
> corrections to description in case we decide to keep this patch.

Thanks.  I have merged your new description.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
