Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
	works on memoryless node.
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080205153326.5c820dbc.pj@sgi.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080202090914.GA27723@one.firstfloor.org>
	 <20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1202149243.5028.61.camel@localhost> <20080205041755.3411b5cc.pj@sgi.com>
	 <alpine.DEB.0.9999.0802051146300.5854@chino.kir.corp.google.com>
	 <20080205145141.ae658c12.pj@sgi.com>
	 <alpine.DEB.1.00.0802051259090.26206@chino.kir.corp.google.com>
	 <20080205153326.5c820dbc.pj@sgi.com>
Content-Type: text/plain
Date: Tue, 05 Feb 2008 17:04:30 -0500
Message-Id: <1202249070.5332.58.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: David Rientjes <rientjes@google.com>, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-05 at 15:33 -0600, Paul Jackson wrote:
> David wrote:
> > It would be disappointing to see a lot of work done to fix
> 
> The suggested patch of KOSAKI Motohiro didn't look like a lot of work to me.
> 
> I continue to prefer not to hijack this thread for that other discussion.
> Just presenting your position and calling it "simple" is misleading.
> The discussion so far has involved over a hundred messages over months,
> and certainly your position, nor mine for that matter, obtained concensus.
> 
> How does the patch of KOSAKI Motohiro, earlier in this thread, look to you?
> 

Paul,

It wasn't clear to me whether Kosaki-san's patch required a modified
numactl/libnuma or not.   I think so, because that patch doesn't change
the error return in contextualize_policy() and in mpol_check_policy().
My modified numactl/libnuma avoids this by only passing in allowed mems
fetch via get_mempolicy() with the new MEMS_ALLOWED flags.

The patch I just posted doesn't depend on the numactl changes and seems
quite minimal to me.  I think it cleans up the differences between
set_mempolicy() and mbind(), as well.  However, some may take exception
to the change in behavior--silently ignoring dis-allowed nodes in
set_mempolicy().

Also, your cpuset/mempolicy work will probably need to undo the
unconditional masking in contextualize_policy() and/or save the original
node mask somewhere...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
