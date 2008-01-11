Date: Fri, 11 Jan 2008 11:06:22 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080111110622.52604fdc@bree.surriel.com>
In-Reply-To: <1200066610.5304.11.camel@localhost>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1200066610.5304.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 10:50:09 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Again, my doing.  I agree that the calculation is a bit strange, but I
> wanted to "future-proof" this function in case we ever get to a value of
> '6' for the lru_list enum.  In that case, the AND will evaluate to
> non-zero for what may not be a file LRU.  Between the build time
> assertion and the division [which could just be a 'l >> 1', I suppose]
> we should be safe.

Good point.  I did not guess that.

I'll restore the code to your original test.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
