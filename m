Date: Fri, 11 Jan 2008 11:15:37 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080111111537.6bd2f5e4@bree.surriel.com>
In-Reply-To: <1200067158.5304.17.camel@localhost>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080111104258.2d1df3de@bree.surriel.com>
	<1200067158.5304.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 10:59:18 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Fri, 2008-01-11 at 10:42 -0500, Rik van Riel wrote:
> > On Fri, 11 Jan 2008 15:24:34 +0900
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > below patch is a bit cleanup proposal.
> > > i think LRU_FILE is more clarify than "/2".
> > > 
> > > What do you think it?
> > 
> > Thank you for the cleanup, your version looks a lot nicer.  
> > I have applied your patch to my series.
> > 
> 
> Rik:  
> 
> I think we also want to do something like:
> 
> -	BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
> +	BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3 ||
> +		NR_LRU_LISTS > 6);
> 
> Then we'll be warned if future change might break our implicit
> assumption that any lru_list value with '0x2' set is a file lru.

Restoring the code to your original version makes things work again.

OTOH, I almost wonder if we should not simply define it to

	return (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE)

and just deal with it.

Your version of the code is correct and probably faster, but not as
easy to read and probably not in a hot path :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
