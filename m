Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8C86B0280
	for <linux-mm@kvack.org>; Mon, 10 May 2010 07:46:25 -0400 (EDT)
Subject: Re: [PATCH 12/25] lmb: Move lmb arrays to static storage in lmb.c
 and make their size a variable
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20100510104446.GC14278@linux-sh.org>
References: <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
	 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
	 <20100510104446.GC14278@linux-sh.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 May 2010 21:46:14 +1000
Message-ID: <1273491974.23699.90.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Mon, 2010-05-10 at 19:44 +0900, Paul Mundt wrote:
> Perhaps it would be better to weight this against MAX_ACTIVE_REGIONS
> for the ARCH_POPULATES_NODE_MAP case? The early node map is already
> using that size, at least. 

Well, one of the next patches implement dynamic resize of the LMB array
so I was actually thinking about shrinking the static one to a
minimum...

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
