Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <Pine.LNX.3.95.1020718144203.1123A-100000@chaos.analogic.com>
References: <Pine.LNX.3.95.1020718144203.1123A-100000@chaos.analogic.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 18 Jul 2002 12:10:14 -0700
Message-Id: <1027019414.1085.143.camel@sinai>
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

I should also mention this is demand paging, not overcommit.

Overcommit is the property of succeeded more allocations than their is
memory in the address space.  The idea being that allocations are lazy,
things often do not use their full allocations, etc. etc. as you
mentioned.

It is typical a good thing since it lowers VM pressure.

It is not always a good thing, for numerous reasons, and it becomes
important in those scenarios to ensure that all allocations can be met
by the backing store and consequently we never find ourselves with more
memory committed than available and thus never OOM.

This has nothing to do with paging and resource limits as you say.  Btw,
without this it is possible to OOM any machine.  OOM is a by-product of
allowing overcommit and poor accounting (and perhaps poor
software/users), not an incorrectly configured machine.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
