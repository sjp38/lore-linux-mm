Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 90AAC6B0095
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 01:50:13 -0500 (EST)
Date: Thu, 14 Jan 2010 08:50:08 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v5] add MAP_UNLOCKED mmap flag
Message-ID: <20100114065008.GC18808@redhat.com>
References: <20100113093119.GT7549@redhat.com>
 <20100114092845.D719.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114092845.D719.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 09:31:03AM +0900, KOSAKI Motohiro wrote:
> > If application does mlockall(MCL_FUTURE) it is no longer possible to mmap
> > file bigger than main memory or allocate big area of anonymous memory
> > in a thread safe manner. Sometimes it is desirable to lock everything
> > related to program execution into memory, but still be able to mmap
> > big file or allocate huge amount of memory and allow OS to swap them on
> > demand. MAP_UNLOCKED allows to do that.
> >  
> > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > ---
> > 
> > I get reports that people find this useful, so resending.
> 
> This description is still wrong. It doesn't describe why this patch is useful.
> 
I think the text above describes the feature it adds and its use
case quite well. Can you elaborate what is missing in your opinion,
or suggest alternative text please?

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
