Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A592E6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:23:10 -0400 (EDT)
Date: Mon, 16 Mar 2009 21:22:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Point the UNEVICTABLE_LRU config option at the documentation
In-Reply-To: <20090316120224.GA16506@infradead.org>
References: <20090316105945.18131.82359.stgit@warthog.procyon.org.uk> <20090316120224.GA16506@infradead.org>
Message-Id: <20090316211830.1FE8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Howells <dhowells@redhat.com>, lee.schermerhorn@hp.com, minchan.kim@gmail.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, Mar 16, 2009 at 10:59:45AM +0000, David Howells wrote:
> > Point the UNEVICTABLE_LRU config option at the documentation describing the
> > option.
> 
> Didn't we decide a while ago that the option is pointless and the code
> should always be enabled?

Yeah.
CONFIG_UNEVICTABLE_LRU lost existing reason by David's good patch recently.

if nobody of nommu user post bug report in .30 age, I plan to remove
this config option at .31 age.

his patch is really really good job.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
