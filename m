Date: Sat, 20 Apr 2002 16:29:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] rmap 13
Message-ID: <20020420232938.GH21206@holomorphy.com>
References: <Pine.LNX.4.44L.0204201731220.1960-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0204201731220.1960-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, Martin.Bligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, Apr 20, 2002 at 05:32:19PM -0300, Rik van Riel wrote:
> Better SMP scalability, first batch of lock breakup work. Still
> experimental, but testing is very much welcome...
...
[general comments]
> My big TODO items for a next release are:
>   - O(1) page launder - currently functional but slow, needs to be tuned
>   - pte-highmem

If I can clarify a bit, I'm deferring submission of the subsequent bits
of the lock breakups in order to to expose the various stages of it to
wider testing individually. One can't be too careful with these changes.

Also, Martin Bligh is the original author of the per-page pte_chain
locking patch.


More to come,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
