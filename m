Date: Tue, 10 Jun 2008 17:14:00 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-ID: <20080610171400.149886cf@cuia.bos.redhat.com>
In-Reply-To: <20080610033130.GK19404@wotan.suse.de>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.522708682@redhat.com>
	<20080606180746.6c2b5288.akpm@linux-foundation.org>
	<20080610033130.GK19404@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 05:31:30 +0200
Nick Piggin <npiggin@suse.de> wrote:

> If we eventually run out of page flags on 32 bit, then sure this might be
> one we could look at geting rid of. Once the code has proven itself.

Yes, after the code has proven stable, we can probably get
rid of the PG_mlocked bit and use only PG_unevictable to mark
these pages.

Lee, Kosaki-san, do you see any problem with that approach?
Is the PG_mlocked bit really necessary for non-debugging
purposes?

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
