Date: Mon, 9 Sep 2002 15:49:28 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] modified segq for 2.5
Message-ID: <20020909224928.GH18800@holomorphy.com>
References: <3D7CF077.FB251EC7@digeo.com> <Pine.LNX.4.44L.0209091622470.1857-100000@imladris.surriel.com> <3D7D09D7.2AE5AD71@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D7D09D7.2AE5AD71@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Rik van Riel <riel@conectiva.com.br>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
>> Move them to the inactive list the moment we're done writing
>> them, that is, the moment we move on to the next page. We
>> wouldn't want to move the last page from /var/log/messages to
>> the inactive list all the time ;)

On Mon, Sep 09, 2002 at 01:51:35PM -0700, Andrew Morton wrote:
> The moment "who" has done writing them?  Some writeout
> comes in via shrink_foo() and a ton of writeout comes in
> via balance_dirty_pages(), pdflush, etc.
> Do we need to distinguish between the various contexts?

Ideally some distinction would be nice, even if only to distinguish I/O
demanded to be done directly by the workload from background writeback
and/or readahead.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
