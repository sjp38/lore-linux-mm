Date: Thu, 17 Jan 2002 22:56:38 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH *] rmap VM 11c
In-Reply-To: <012d01c19fb7$ba1cb680$02c8a8c0@kroptech.com>
Message-ID: <Pine.LNX.4.33L.0201172254580.32617-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Kropelin <akropel1@rochester.rr.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jan 2002, Adam Kropelin wrote:
> Rik van Riel <riel@conectiva.com.br>:
> > For this release, IO tests are very much welcome ...
>
> Results from a run of my large FTP transfer test on this new release
> are... interesting.
>
> Overall time shows an improvement (6:28), though not enough of one to
> take the lead over 2.4.13-ac7.

> (i.e., nice steady writeout reminiscent of -ac)
> ...but after about 20 seconds, behavior degrades again:
>
> Previous tests showed fluctuating bo values from the start; this is the first
> time I've seen them steady, so something in the patch definitely is showing
> through here.

Thank you for running this test.  I'll try to debug the situation
and see what's going on ... this definately isn't behaving like
it should.

kind regards,

Rik
-- 
"Linux holds advantages over the single-vendor commercial OS"
    -- Microsoft's "Competing with Linux" document

http://www.surriel.com/		http://distro.conectiva.com/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
