Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFE06B063B
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 19:07:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x28so149067wma.7
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:07:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h65si259325wmh.58.2017.08.02.16.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 16:07:18 -0700 (PDT)
Date: Wed, 2 Aug 2017 16:07:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: use per-cpu unbuddied lists
Message-Id: <20170802160716.f5d1072873799a3a420f6538@linux-foundation.org>
In-Reply-To: <20170802122505.e41d5c778a873375bcb0cc19@gmail.com>
References: <20170802122505.e41d5c778a873375bcb0cc19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Oleksiy.Avramchenko@sony.com

On Wed, 2 Aug 2017 12:25:05 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> z3fold is operating on unbuddied lists in a simple manner: in fact,
> it only takes the first entry off the list on a hot path. So if the
> z3fold pool is big enough and balanced well enough, considering
> only the lists local to the current CPU won't be an issue in any
> way, while random I/O performance will go up.

Has the performance benefit been measured?  It's a large patch.

> This patch also introduces two worker threads which: one for async
> in-page object layout optimization and one for releasing freed
> pages.

Why?  What are the runtime effects of this change?  Does this turn
currently-synchronous operations into now-async operations?  If so,
what are the implications of this if, say, the workqueue doesn't get
serviced for a while?

etc.  Sorry, but I'm not seeing anywhere near enough information and
testing results to justify merging such a large and intrusive patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
