Subject: Re: [PATCH] 2.4.20-rmap15a
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
From: Sean Neakums <sneakums@zork.net>
Date: Tue, 03 Dec 2002 16:39:06 +0000
In-Reply-To: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com> (Rik
 van Riel's message of "Sun, 1 Dec 2002 18:35:50 -0200 (BRST)")
Message-ID: <6usmxfys45.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: dave@zork.net
List-ID: <linux-mm.kvack.org>

commence  Rik van Riel quotation:

> This is a merge of rmap15a with marcelo's 2.4 bitkeeper tree,
> which is identical to 2.4.20-rc4 (he didn't push the makefile
> update).  The only thing left out of the merge for now is
> Andrew Morton's read_latency patch, both because I'm not sure
> how needed it is with the elevator updates and because this
> part of the merge was too tricky to do at merge time; I'll port
> over Andrew Morton's read_latency patch later...

I'm seeing a difference in wall-clock time of about nine minutes for
an lnx-bbc build (http://www.lnx-bbc.org/).  Dave Barry, another
lnx-bbc developer, has observed something similar.  The difference in
system times seems to be above noise, too.  Both of the kernels I used
also had Stephen Tweedie's ext3 updates for 2.4.20 applied[0].  I can
retest without, if you wish.  I believe Dave's kernels had only rmap
applied, however.

2.4.20:
real    106m26.147s
user    62m54.340s
sys     26m54.670s

2.4.20-rmap15a:
real    115m5.283s
user    63m50.580s
sys     29m34.520s

I used ccache with these builds and they are almost entirely cached
(the big exception being gcc), so the job becomes fairly I/O-bound as
a result.  The builds are quite big: the CVS tree unpacks and builds
about three hundred megabytes of source, resulting in a build
footprint of approximately 2.9GiB.  The volume I used for the build is
formatted as ext3, with htree activated.  (I originally started using
those patches because I had found that previous htree patches b0rked
during an lnx-bbc build.)


[0]  http://people.redhat.com/sct/patches/ext3-2.4/dev-20021115/

-- 
 /                          |
[|] Sean Neakums            |  Questions are a burden to others;
[|] <sneakums@zork.net>     |      answers a prison for oneself.
 \                          |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
