Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 426816B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 13:09:13 -0400 (EDT)
From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
Date: Thu, 25 Jun 2009 20:10:33 +0300
References: <1245839904.3210.85.camel@localhost.localdomain> <200906251646.22785.a1426z@gawab.com> <20090625144450.GT31415@kernel.dk>
In-Reply-To: <20090625144450.GT31415@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200906252010.33535.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> The test case is random mmap writes to files that have been laid out
> sequentially. So it's all seeks. The target drive is an SSD disk though,
> so it doesn't matter a whole lot (it's a good SSD).

Oh, SSD.  What numbers do you get for normal disks?


Thanks!

--
Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
