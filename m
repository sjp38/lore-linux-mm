Date: Fri, 8 Feb 2002 09:53:35 +0100
From: Jens Axboe <axboe@suse.de>
Subject: Re: [PATCH *] rmap VM 12d
Message-ID: <20020208095335.I4942@suse.de>
References: <Pine.LNX.4.33L.0202072127490.17850-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0202072127490.17850-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 07 2002, Rik van Riel wrote:
>   - fix starvation issue in get_request_wait()

I'm currently fixing this (non-trivial) problem in 2.5, I'll do a 2.4
back port afterwards. Hopefully with the same structure, if it doesn't
become too big a change.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
