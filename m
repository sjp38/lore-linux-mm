Date: Mon, 7 May 2001 19:10:04 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: about profiling and stats info for pagecache/buffercache
Message-ID: <20010507191004.R4077@redhat.com>
References: <200105061800.OAA20123@datafoundation.com> <Pine.LNX.4.21.0105061636020.582-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105061636020.582-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Sun, May 06, 2001 at 04:42:04PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alexey Zhuravlev <alexey@datafoundation.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, May 06, 2001 at 04:42:04PM -0300, Rik van Riel wrote:
> 
> I'd like to see a few other statistics as well, mainly for the
> pageout code...
> 
> - nr pages scannned
> - nr pages moved to the inactive_clean list
> - nr pages "rescued" from the inactive_clean list
> - nr pages evicted
> - nr pages deactivated by pageout scanning
> - nr pages deactivated by drop-behind
> 
> Are there any more ideas for statistics people would like to
> see?

As long as that's per-zone, and includes failed scans as well as
successes, fine.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
