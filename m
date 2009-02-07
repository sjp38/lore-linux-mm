Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CA8B36B003D
	for <linux-mm@kvack.org>; Sat,  7 Feb 2009 16:20:12 -0500 (EST)
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
From: Nigel Cunningham <ncunningham-lkml@crca.org.au>
Reply-To: ncunningham-lkml@crca.org.au
In-Reply-To: <2f11576a0902070851q7d478679i8a47ad9b3810dc0e@mail.gmail.com>
References: <20090206031125.693559239@cmpxchg.org>
	 <20090206031324.004715023@cmpxchg.org>
	 <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20090206044907.GA18467@cmpxchg.org>
	 <20090206130009.99400d43.akpm@linux-foundation.org>
	 <2f11576a0902070851q7d478679i8a47ad9b3810dc0e@mail.gmail.com>
Content-Type: text/plain
Date: Sun, 08 Feb 2009 08:20:51 +1100
Message-Id: <1234041651.7277.5.camel@nigel-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, rjw@sisk.pl, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Sun, 2009-02-08 at 01:51 +0900, KOSAKI Motohiro wrote:
> akpm wrote:
> --------------
>  And what was the observed effect of all this?
> 
> Rafael wrote:
> --------------
> Measurable effects:
> 1) It tends to free only as much memory as required, eg. if the image_size
> is set to 450 MB, the actual image sizes are almost always well above
> 400 MB and they tended to be below that number without the patch
> (~5-10% of a difference, but still :-)).

Do you always get at least the number of pages you ask for, if that's
possible?

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
