Date: Thu, 3 Aug 2000 17:04:27 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: RFC: design for new VM
In-Reply-To: <20000804071129.A4354@metastasis.f00f.org>
Message-ID: <Pine.LNX.3.96.1000803170212.16915D-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: Linus Torvalds <torvalds@transmeta.com>, lamont@icopyright.com, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Please don't make this kind of head-stuck-in-sand argument before you've
had a chance to test the code.  If anything, choosing the correct page for
replacement is *more* important on a 4MB 386 where disks are typically
1/20th the speed of a desktop.

		-ben

On Fri, 4 Aug 2000, Chris Wedgwood wrote:

> No, I don't think it does -- so for people running <= 1 1GB of ram
> perhasp there should be a compile time option to not have all this
> additional stuff linux will require?
> 
> 
>   --cw
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
