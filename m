Date: Sat, 23 Sep 2000 17:49:38 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: test9-pre6 and GFP_BUFFER allocations
In-Reply-To: <39CCCC15.DB052A65@norran.net>
Message-ID: <Pine.LNX.4.21.0009231749001.5934-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Sep 2000, Roger Larsson wrote:

> * Won't we end up in an infinite loop?

FYI, i still see a rare deadlock, even under test9-pre6.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
