Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 7E1826B004D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 22:29:32 -0400 (EDT)
Message-ID: <1343096969.7412.21.camel@marge.simpson.net>
Subject: Re: [MMTests] Sysbench read-only on ext3
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 24 Jul 2012 04:29:29 +0200
In-Reply-To: <20120723211334.GA9222@suse.de>
References: <20120620113252.GE4011@suse.de> <20120629111932.GA14154@suse.de>
	 <20120723211334.GA9222@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2012-07-23 at 22:13 +0100, Mel Gorman wrote:

> The backing database was postgres.

FWIW, that wouldn't have been my choice.  I don't know if it still does,
but it used to use userland spinlocks to achieve scalability.  Turning
your CPUs into space heaters to combat concurrency issues makes a pretty
flat graph, but probably doesn't test kernels as well as something that
did not do that.

-Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
