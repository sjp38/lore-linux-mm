Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.3.95.1020718144203.1123A-100000@chaos.analogic.com>
References: <Pine.LNX.3.95.1020718144203.1123A-100000@chaos.analogic.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 12:03:16 -0700
Message-Id: <1027018996.1116.136.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: Szakacsits Szabolcs <szaka@sienet.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-07-18 at 11:56, Richard B. Johnson wrote:

> What should have happened is each of the tasks need only about
> 4k until they actually access something. Since they can't possibly
> access everything at once, we need to fault in pages as needed,
> not all at once. This is what 'overcomit' is, and it is necessary.

Then do not enable strict overcommit, Dick.

> If you have 'fixed' something so that no RAM ever has to be paged
> you have a badly broken system.

That is not the intention of Alan or I's work at all.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
