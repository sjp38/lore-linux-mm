Subject: Re: [PATCH] strict VM overcommit for stock 2.4
From: Robert Love <rml@tech9.net>
In-Reply-To: <20020719221957.068f8323.shahamit@gmx.net>
References: <Pine.LNX.3.95.1020718144203.1123A-100000@chaos.analogic.com>
	<1027018996.1116.136.camel@sinai>
	<20020719221957.068f8323.shahamit@gmx.net>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 19 Jul 2002 10:16:58 -0700
Message-Id: <1027099018.1086.179.camel@sinai>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amit Shah <shahamit@gmx.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2002-07-19 at 09:49, Amit Shah wrote:
> One question: do you have a strict vm overcommit patch for 2.4.18?

Yes, I have made patches for 2.4 and 2.5 with and without rmap.  See,

http://www.kernel.org/pub/linux/kernel/people/rml/vm/strict-overcommit/

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
