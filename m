Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 85FA46B006C
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 15:39:20 -0500 (EST)
Date: Fri, 15 Feb 2013 15:39:13 -0500 (EST)
Message-Id: <20130215.153913.1285091915738918107.davem@davemloft.net>
Subject: Re: [patch 1/2] mm: fincore()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20130215063450.GA24047@cmpxchg.org>
References: <20130211162701.GB13218@cmpxchg.org>
	<20130211141239.f4decf03.akpm@linux-foundation.org>
	<20130215063450.GA24047@cmpxchg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, npiggin@suse.de, stewart@flamingspork.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

From: Johannes Weiner <hannes@cmpxchg.org>
Date: Fri, 15 Feb 2013 01:34:50 -0500

> +	nr_pages = DIV_ROUND_UP(len, PAGE_CACHE_SIZE);

A small nit, maybe use PAGE_CACHE_ALIGN() here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
