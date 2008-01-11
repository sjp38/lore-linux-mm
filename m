Date: Fri, 11 Jan 2008 10:42:58 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080111104258.2d1df3de@bree.surriel.com>
In-Reply-To: <20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
	<20080111143627.FD64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Jan 2008 15:24:34 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> below patch is a bit cleanup proposal.
> i think LRU_FILE is more clarify than "/2".
> 
> What do you think it?

Thank you for the cleanup, your version looks a lot nicer.  
I have applied your patch to my series.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
