Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 73D296B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 19:13:44 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id fp1so1622499pdb.30
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 16:13:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id py7si12395824pbb.251.2014.06.16.16.13.43
        for <linux-mm@kvack.org>;
        Mon, 16 Jun 2014 16:13:43 -0700 (PDT)
Date: Mon, 16 Jun 2014 16:13:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: simplify drain_zone_pages by using
 min()
Message-Id: <20140616161341.2f677b79afb4da9250fd4282@linux-foundation.org>
In-Reply-To: <1402952894-13200-1-git-send-email-mina86@mina86.com>
References: <1402952894-13200-1-git-send-email-mina86@mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 16 Jun 2014 23:08:14 +0200 Michal Nazarewicz <mina86@mina86.com> wrote:

> Instead of open-coding getting minimal value of two, just use min macro.
> That is why it is there for.  While changing the function also change
> type of batch local variable to match type of per_cpu_pages::batch
> (which is int).
> 

I'm not sure why we made all the per_cpu_pages mambers `int'.  Unsigned
would make more sense.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
