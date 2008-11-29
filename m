Date: Sat, 29 Nov 2008 10:51:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
Message-Id: <20081129105120.cfb8c035.akpm@linux-foundation.org>
In-Reply-To: <49318CDE.4020505@redhat.com>
References: <20081128060803.73cd59bd@bree.surriel.com>
	<20081128231933.8daef193.akpm@linux-foundation.org>
	<4931721D.7010001@redhat.com>
	<20081129094537.a224098a.akpm@linux-foundation.org>
	<493182C8.1080303@redhat.com>
	<20081129102608.f8228afd.akpm@linux-foundation.org>
	<49318CDE.4020505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, 29 Nov 2008 13:41:34 -0500 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Sat, 29 Nov 2008 12:58:32 -0500 Rik van Riel <riel@redhat.com> wrote:
> > 
> >>> Will this new patch reintroduce the problem which
> >>> 26e4931632352e3c95a61edac22d12ebb72038fe fixed?
> 
> No, that problem is already taken care of by the fact that
> active pages always get deactivated in the current VM,
> regardless of whether or not they were referenced.

err, sorry, that was the wrong commit. 
26e4931632352e3c95a61edac22d12ebb72038fe _introduced_ the problem, as
predicted in the changelog.

265b2b8cac1774f5f30c88e0ab8d0bcf794ef7b3 later fixed it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
