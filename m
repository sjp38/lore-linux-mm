Date: Wed, 19 Mar 2008 17:09:37 -0700 (PDT)
Message-Id: <20080319.170937.247919863.davem@davemloft.net>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080319161211.2df88adc.akpm@linux-foundation.org>
References: <20080319020440.80379d50.akpm@linux-foundation.org>
	<a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
	<20080319161211.2df88adc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 19 Mar 2008 16:12:11 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: drepper@gmail.com, andi@firstfloor.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I did some work on that many years ago and I do recall that it
> helped, but I forget how much.

I wrote such a patch ages ago as well.

Frankly, based upon my experiences then and what I know now, I think
it's a lose to do this.

Better to 1) have enough ram and 2) make the reclaim smarter about
important "executable" page cache pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
