Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A88F26B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 15:40:38 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so795182fga.8
        for <linux-mm@kvack.org>; Thu, 03 Sep 2009 12:40:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090831074221.GA10263@localhost>
References: <20090831074221.GA10263@localhost>
Date: Thu, 3 Sep 2009 22:40:40 +0300
Message-ID: <84144f020909031240g3b040eadxd4fd6f662f0b250d@mail.gmail.com>
Subject: Re: [PATCH] slqb: add common slab debug bits
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 10:42 AM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> This is a simple copy&paste from slub.c:
>
> - lockdep annotation
> - might sleep annotation
> - fault injection
>
> CC: Nick Piggin <nickpiggin@yahoo.com.au>
> CC: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
