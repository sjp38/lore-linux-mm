Date: Fri, 19 Jul 2002 22:19:57 +0530
From: Amit Shah <shahamit@gmx.net>
Subject: Re: [PATCH] strict VM overcommit for stock 2.4
Message-Id: <20020719221957.068f8323.shahamit@gmx.net>
In-Reply-To: <1027018996.1116.136.camel@sinai>
References: <Pine.LNX.3.95.1020718144203.1123A-100000@chaos.analogic.com>
	<1027018996.1116.136.camel@sinai>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One question: do you have a strict vm overcommit patch for 2.4.18?

On 18 Jul 2002 12:03:16 -0700
Robert Love <rml@tech9.net> wrote:

RL> On Thu, 2002-07-18 at 11:56, Richard B. Johnson wrote:
RL> 
RL> > What should have happened is each of the tasks need only about
RL> > 4k until they actually access something. Since they can't possibly
RL> > access everything at once, we need to fault in pages as needed,
RL> > not all at once. This is what 'overcomit' is, and it is necessary.
RL> 
RL> Then do not enable strict overcommit, Dick.
RL> 
RL> > If you have 'fixed' something so that no RAM ever has to be paged
RL> > you have a badly broken system.
RL> 
RL> That is not the intention of Alan or I's work at all.
RL> 
RL> 	Robert Love

--- 

  - Amit
Want to know more about me? Follow this link-> http://amitshah.nav.to/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
