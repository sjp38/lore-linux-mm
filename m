Date: Sun, 13 Oct 2002 13:42:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.42-mm2
Message-ID: <20021013204244.GD2032@holomorphy.com>
References: <20021013195236.GC27878@holomorphy.com> <Pine.LNX.4.44L.0210131803400.22735-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0210131803400.22735-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 13 Oct 2002, William Lee Irwin III wrote:
>> (1) It's embedded in struct zone, hence bootmem allocated, hence
>> 	already zeroed.

On Sun, Oct 13, 2002 at 06:04:02PM -0200, Rik van Riel wrote:
> The struct zone doesn't get automatically zeroed on all architectures.

It actually doesn't come out of bootmem. It's tacked onto min_low_pfn
because it's being dynamically allocated prior to init_bootmem().


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
