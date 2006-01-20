Date: Fri, 20 Jan 2006 21:08:49 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [PATCH 0/5] Reducing fragmentation using zones
In-Reply-To: <Pine.LNX.4.58.0601200934300.10920@skynet>
References: <43D03C24.5080409@jp.fujitsu.com> <Pine.LNX.4.58.0601200934300.10920@skynet>
Message-Id: <20060120210353.1269.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> What sort of tests would you suggest? The tests I have been running to
> date are
> 
> "kbuild + aim9" for regression testing
> 
> "updatedb + 7 -j1 kernel compiles + highorder allocation" for seeing how
> easy it was to reclaim contiguous blocks

BTW, is "highorder allocation test" your original test code?
If so, just my curious, I would like to see it too. ;-).

Bye.
-- 
Yasunori Goto 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
