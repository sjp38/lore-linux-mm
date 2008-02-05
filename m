Date: Tue, 5 Feb 2008 14:51:41 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
Message-Id: <20080205145141.ae658c12.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.9999.0802051146300.5854@chino.kir.corp.google.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080202090914.GA27723@one.firstfloor.org>
	<20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1202149243.5028.61.camel@localhost>
	<20080205041755.3411b5cc.pj@sgi.com>
	<alpine.DEB.0.9999.0802051146300.5854@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Lee.Schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

David wrote:
> The more alarming result of these remaps is in the MPOL_BIND case, as 
> we've talked about before.  The language in set_mempolicy(2):

You're diving into the middle of a rather involved discussion
we had on the other various patches proposed to extend the
interaction of mempolicy's with cpusets and hotplug.

I choose not to hijack this current thread with my rebuttal,
which you've seen before, of your points here.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
