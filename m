Date: Sun, 12 Jan 2003 15:36:55 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Linux VM Documentation - Draft 1
In-Reply-To: <200301121511.RAA22153@infa.abo.fi>
Message-ID: <Pine.LNX.4.44.0301121532160.24444-100000@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcus Alanen <marcus@infa.abo.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Jan 2003, Marcus Alanen wrote:

> Excellent! A lot of people will learn from this, thank you!
>

Your welcome!

> Do you take patches? I couldn't find the .tex file.
>

I wasn't sure how suitable patches would be for documentation but I'll try
anything once. A tar ball of the current tex source is at
http://www.csn.ul.ie/~mel/projects/vm/guide/vm_book.tar.gz . There is a
CVS tree but it's on a computer thats already heavily loaded so I don't
want to have it hammered.

The tex sources are in tex/understand and tex/code . To create a DVI,
simply ./make dvi . If you add "understand" or "code", it'll just generate
that book.

-- 
Mel Gorman
MSc Student, University of Limerick
http://www.csn.ul.ie/~mel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
