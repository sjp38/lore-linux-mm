Message-ID: <49318CDE.4020505@redhat.com>
Date: Sat, 29 Nov 2008 13:41:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
References: <20081128060803.73cd59bd@bree.surriel.com>	<20081128231933.8daef193.akpm@linux-foundation.org>	<4931721D.7010001@redhat.com>	<20081129094537.a224098a.akpm@linux-foundation.org>	<493182C8.1080303@redhat.com> <20081129102608.f8228afd.akpm@linux-foundation.org>
In-Reply-To: <20081129102608.f8228afd.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sat, 29 Nov 2008 12:58:32 -0500 Rik van Riel <riel@redhat.com> wrote:
> 
>>> Will this new patch reintroduce the problem which
>>> 26e4931632352e3c95a61edac22d12ebb72038fe fixed?

No, that problem is already taken care of by the fact that
active pages always get deactivated in the current VM,
regardless of whether or not they were referenced.

> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/old-2.6-bkcvs.git
> 
> Spending a couple of fun hours reading `git-log mm/vmscan.c' is pretty
> instructive.  For some reason that command generates rather a lot of
> unrelated changelog info which needs to be manually skipped over.

Will do.  Thank you for the pointer.

(and not sure why google wouldn't find it - it finds other
git changesets...)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
