Date: Wed, 12 Apr 2006 13:49:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH] support for oom_die
Message-Id: <20060412134956.66857492.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060412101154.019e9cb3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
	<20060412101154.019e9cb3.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, dgc@sgi.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Apr 2006 10:11:54 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Why they want panic at OOM ?
> 

David-san, Rik-san,  thank you for comments.
I'm convinced there are some cases where panic is better than kill , again.

I'll fix my corrupt English and post this patch to lkml with proper description.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
