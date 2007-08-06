Date: Mon, 6 Aug 2007 11:21:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: make swappiness safer to use
Message-Id: <20070806112154.f8c5bcdc.akpm@linux-foundation.org>
In-Reply-To: <20070801023315.GB6910@v2.random>
References: <20070731215228.GU6910@v2.random>
	<20070731151244.3395038e.akpm@linux-foundation.org>
	<20070731224052.GW6910@v2.random>
	<20070731155109.228b4f19.akpm@linux-foundation.org>
	<20070731230251.GX6910@v2.random>
	<20070801011925.GB20109@mail.ustc.edu.cn>
	<20070801012222.GA20565@mail.ustc.edu.cn>
	<20070801013208.GA20085@mail.ustc.edu.cn>
	<20070801023315.GB6910@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Fengguang Wu <fengguang.wu@gmail.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Aug 2007 04:33:15 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> On Wed, Aug 01, 2007 at 09:32:08AM +0800, Fengguang Wu wrote:
> > Here's the updated patch without underflows.
> 
> this is ok.

I lost the plot a bit here.  Can I please have a resend of the full and
final patch?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
