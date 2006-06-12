From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number =?utf-8?q?of=09physical_pages_backing?= it
Date: Mon, 12 Jun 2006 19:58:40 +0200
References: <1149903235.31417.84.camel@galaxy.corp.google.com> <448A762F.7000105@yahoo.com.au> <1150133795.9576.19.camel@galaxy.corp.google.com>
In-Reply-To: <1150133795.9576.19.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606121958.41127.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rohitseth@google.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> It is just the price of those walks that makes smaps not an attractive
> solution for monitoring purposes.

It just shouldn't be used for that. It's a debugging hack and not really 
suitable for monitoring even with optimizations.

For monitoring if the current numa statistics are not good enough
you should probably propose new counters.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
