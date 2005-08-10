Date: Wed, 10 Aug 2005 13:31:25 -0700 (PDT)
Message-Id: <20050810.133125.08323684.davem@davemloft.net>
Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement
From: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050810200943.809832000@jumble.boston.redhat.com>
References: <20050810200216.644997000@jumble.boston.redhat.com>
	<20050810200943.809832000@jumble.boston.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Rik van Riel <riel@redhat.com>
Date: Wed, 10 Aug 2005 16:02:20 -0400
Return-Path: <owner-linux-mm@kvack.org>
To: riel@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> +DEFINE_PER_CPU(unsigned long, evicted_pages);

DEFINE_PER_CPU() needs an explicit initializer to work
around some bugs in gcc-2.95, wherein on some platforms
if you let it end up as a BSS candidate it won't end up
in the per-cpu section properly.

I'm actually happy you made this mistake as it forced me
to audit the whole current 2.6.x tree and there are few
missing cases in there which I'll fix up and send to Linus.
:-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
