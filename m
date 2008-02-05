Date: Tue, 5 Feb 2008 13:15:17 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [2.6.24-rc8-mm1][regression?] numactl --interleave=all doesn't
 works on memoryless node.
Message-Id: <20080205131517.1189104f.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802051050300.12425@schroedinger.engr.sgi.com>
References: <20080202165054.F491.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080202090914.GA27723@one.firstfloor.org>
	<20080202180536.F494.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<1202149243.5028.61.camel@localhost>
	<20080205143149.GA4207@csn.ul.ie>
	<1202225017.5332.1.camel@localhost>
	<Pine.LNX.4.64.0802051011400.11705@schroedinger.engr.sgi.com>
	<1202236056.5332.17.camel@localhost>
	<Pine.LNX.4.64.0802051050300.12425@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Can we fix up his patch to address the immediate issue?

Since any of those future patches only add optional modes
with new flags, while preserving current behaviour if you
don't use one of the new flags, therefore the current behavior
has to work as best it can.

Therefore fixes such as this to address immediate issues
are probably needed.  Yup.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
