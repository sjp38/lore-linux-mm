Date: Mon, 16 Dec 2002 01:30:59 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: /proc/meminfo:MemShared
Message-ID: <20021216093059.GJ2690@holomorphy.com>
References: <3DFD9574.38F86231@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DFD9574.38F86231@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 16, 2002 at 12:57:24AM -0800, Andrew Morton wrote:
> Can anyone think of anything useful to print out here,
> or should it just be removed?

It's not indicative of the sharing level, and it's been handing back 0
for a while, so I say kill it.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
