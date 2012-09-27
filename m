Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 36FD86B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 21:47:46 -0400 (EDT)
Date: Thu, 27 Sep 2012 10:50:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] zsmalloc: promote to lib/
Message-ID: <20120927015059.GC10229@bbox>
References: <1348649419-16494-1-git-send-email-minchan@kernel.org>
 <1348649419-16494-2-git-send-email-minchan@kernel.org>
 <CAOJsxLGjp5PAgPe3KSvMfqJEyVC4YHeP+FW3AmnCorpHqnfang@mail.gmail.com>
 <20120927013912.GB10229@bbox>
 <20120926184743.3dca1289.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120926184743.3dca1289.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Jens Axboe <axboe@kernel.dk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2012 at 06:47:43PM -0700, Andrew Morton wrote:
> On Thu, 27 Sep 2012 10:39:12 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > So I and Nitin tried to ask the opinion to akpm several times
> > (at least 5 and even I sent such patch a few month ago) but didn't get
> > any reply from him so I guess he doesn't have any concern about that
> > any more.
> 
> I just haven't yet set aside a sufficiently large lump of time to work
> out what's going on here, sorry.  Will try to get onto it next week. 

Okay. Thanks Andrew.
I will wait your opinion.
Of course, promotion would be stuck by next week.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
