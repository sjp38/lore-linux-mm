Date: Mon, 9 Sep 2002 16:32:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] modified segq for 2.5
Message-ID: <20020909233211.GI18800@holomorphy.com>
References: <20020909224928.GH18800@holomorphy.com> <Pine.LNX.4.44L.0209091953550.1857-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0209091953550.1857-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@digeo.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Sep 2002, William Lee Irwin III wrote:
>> Ideally some distinction would be nice, even if only to distinguish I/O
>> demanded to be done directly by the workload from background writeback
>> and/or readahead.

On Mon, Sep 09, 2002 at 07:54:29PM -0300, Rik van Riel wrote:
> OK, are we talking about page replacement or does queue scanning
> have priority over the quality of page replacement ? ;)

This is relatively tangential. The concern expressed has more to do
with VM writeback starving workload-issued I/O than page replacement.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
