Date: Fri, 4 Oct 2002 01:03:17 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: object based reverse mapping, fundamental problem
Message-ID: <20021004080317.GM12432@holomorphy.com>
References: <Pine.LNX.4.44L.0208091302570.23404-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0208091302570.23404-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: k42@watson.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2002 at 01:11:20PM -0300, Rik van Riel wrote:
> How could we efficiently find all (start, length) mappings
> of the file that have our particular (file, offset) page
> covered ?

K-d trees should suffice to efficiently answer this range query
(since no one else has chimed in) in weeks.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
