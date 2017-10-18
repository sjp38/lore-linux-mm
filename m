Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5CE6B025E
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:15:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f85so3581758pfe.7
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:15:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f29si7040426pgn.736.2017.10.18.07.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 07:15:07 -0700 (PDT)
Date: Wed, 18 Oct 2017 07:15:02 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171018141502.GB12063@bombadil.infradead.org>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <alpine.DEB.2.20.1710181519580.1925@nanos>
 <20171018133019.cwfhnt46pvhirt57@gmail.com>
 <alpine.DEB.2.20.1710181533260.1925@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710181533260.1925@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>, Byungchul Park <byungchul.park@lge.com>, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

On Wed, Oct 18, 2017 at 03:36:05PM +0200, Thomas Gleixner wrote:
> Which reminds me that I wanted to convert them to static_key so they are
> zero overhead when disabled. Sigh, why are todo lists growth only?

This is why you need an Outreachy intern -- it gets at least one task
off your todo list, and in the best possible case, it gets a second
person working on your todo list for a long time.

... eventually they start their own todo lists ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
