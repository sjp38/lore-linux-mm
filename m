Date: Tue, 5 Feb 2008 16:50:58 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
Message-Id: <20080205165058.fdb48527.pj@sgi.com>
In-Reply-To: <1202249070.5332.58.camel@localhost>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080202090914.GA27723@one.firstfloor.org>
	<20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1202149243.5028.61.camel@localhost>
	<20080205041755.3411b5cc.pj@sgi.com>
	<alpine.DEB.0.9999.0802051146300.5854@chino.kir.corp.google.com>
	<20080205145141.ae658c12.pj@sgi.com>
	<alpine.DEB.1.00.0802051259090.26206@chino.kir.corp.google.com>
	<20080205153326.5c820dbc.pj@sgi.com>
	<1202249070.5332.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: rientjes@google.com, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Lee wrote:
> Also, your cpuset/mempolicy work will probably need to undo the
> unconditional masking in contextualize_policy() and/or save the original
> node mask somewhere...

Yeah, something like that ... just a small matter of code.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
