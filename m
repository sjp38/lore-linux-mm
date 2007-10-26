Date: Sat, 27 Oct 2007 08:51:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: migrate_pages() failure
Message-Id: <20071027085137.ed2ea1e0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1193440067.19950.7.camel@dyn9047017100.beaverton.ibm.com>
References: <1193432242.19950.1.camel@dyn9047017100.beaverton.ibm.com>
	<1193440067.19950.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: melgor@ie.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Oct 2007 16:07:47 -0700
Badari Pulavarty <pbadari@gmail.com> wrote:
> Digged up little more ..
> 
> All these pages are "reiserfs" backed file and reiserfs doesn't
> have migratepage() handler. reiserfs_releasepage() gives up
> since one of the buffer_head attached to the page is dirty or locked :(
> 
> Nothing much migrate pages could do :(
> 
Hmm, thank you for reporting.

I've never used reiserfs....:(

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
