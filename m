Date: Fri, 26 May 2000 12:11:39 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000526121139.D10082@redhat.com>
References: <Pine.LNX.4.21.0005240833390.24993-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0005240833390.24993-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, May 24, 2000 at 12:11:35PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Matthew Dillon <dillon@apollo.backplane.com>, "Stephen C. Tweedie" <sct@redhat.com>, Arnaldo Carvalho de Melo <acme@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, May 24, 2000 at 12:11:35PM -0300, Rik van Riel wrote:

> - try to keep about one second worth of allocations around in
>   the inactive queue (we do 100 allocations/second -> at least
>   100 inactive pages), we do this in order to:
>   - get some aging in that queue (one second to be reclaimed)
>   - have enough old pages around to free

Careful here.  If your box is running several Gig Ethernet interfaces,
it could well be allocating 100s of MB of skbuffs every second, each
allocation being very short-lived.  The rate of allocation is not a 
good indicator of memory load.  The rate of allocations which could
not be satisfied immediately would be a far better metric.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
