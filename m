Date: Fri, 13 Sep 2002 09:59:04 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.34-mm3
In-Reply-To: <3D819132.C7171BD9@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209130955580.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rick Lindsley <ricklind@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Sep 2002, Andrew Morton wrote:

> Rik, I didn't include the iowait patch because we don't seem to have
> a tarball of procps which supports it - the various diffs you have at
> http://surriel.com/procps/ appear to be in an intermediate state wrt
> cygnus CVS.

Umm no, the latest patch I put up yesterday is fully in sync
with the cygnus CVS tree ...

> The code is in experimental/iowait.patch.  Could we have a snapshot
> tarball of the support utilities please?

... but I've put up a snapshot, if that makes you happy ;)
The snapshot is of the latest procps code from procps CVS,
including your patch to top.

	http://surriel.com/procps/

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
