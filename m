Date: Thu, 27 Nov 1997 03:04:18 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: pte_list-2.1.66
In-Reply-To: <Pine.LNX.3.91.971125222922.14082B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.971127024507.21730A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hello all,

I updated my pte list patch against 2.1.66, and will be actively working
on it again.  My short term goals include getting the [minimal] work done
needed to make it function on Alphas, and improving the kswapd heuristics
a lot more.  It still probably breaks the shm stuff...  Fetch from
http://www.kvack.org/~blah/patches/pte_list-2.1.66.diff.gz

Also, if people want to discuss mm ideas/developement heavily, I've
created a mailing list (submit to linux-mm@kvack.org, subscribe is
majordomo@kvack.org).  It would be nice to see any rough little mm tweaks
people are hiding. ;)

		-ben
