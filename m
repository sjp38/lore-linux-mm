Date: Mon, 8 Jan 2001 22:33:44 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Linux-2.4.x patch submission policy
Message-ID: <20010108223343.O10035@nightmaster.csn.tu-chemnitz.de>
References: <937neu$p95$1@penguin.transmeta.com> <Pine.LNX.4.21.0101071434370.21675-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0101071434370.21675-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Sun, Jan 07, 2001 at 02:37:47PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jan 07, 2001 at 02:37:47PM -0200, Rik van Riel wrote:
> Once we are sure 2.4 is stable for just about anybody I
> will submit some of the really trivial enhancements for
> inclusion; all non-trivial patches I will maintain in a
> VM bigpatch, which will be submitted for inclusion around
> 2.5.0 and should provide one easy patch for those distribution
> vendors who think 2.4 VM performance isn't good enough for
> them ;)

Hmm, could you instead follow Andreas approach and have a
directory with little patches, that do _exactly_ one thing and a
file along to describe what is related, dependend and what each
patch does?

So people could try to suit them to their needs.

And they can tell you exactly _what_ change breaks instead of "It
doesn't work".

Thanks & Regards

Ingo Oeser
-- 
10.+11.03.2001 - 3. Chemnitzer LinuxTag <http://www.tu-chemnitz.de/linux/tag>
         <<<<<<<<<<<<       come and join the fun       >>>>>>>>>>>>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
