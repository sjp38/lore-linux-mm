Date: Wed, 27 Oct 2004 14:27:00 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041027162659.GA1644@logos.cnet>
References: <20041025213923.GD23133@logos.cnet> <20041026.181504.38310112.taka@valinux.co.jp> <20041026092535.GE24462@logos.cnet> <20041026.230110.21315175.taka@valinux.co.jp> <20041026122419.GD27014@logos.cnet> <20041027072524.EA19F7045D@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041027072524.EA19F7045D@sv1.valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, haveblue@us.ibm.com, hugh@veritas.com, cliffw@osdl.org, judith@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2004 at 04:25:24PM +0900, IWAMOTO Toshihiro wrote:
> At Tue, 26 Oct 2004 10:24:19 -0200,
> Marcelo Tosatti wrote:
> 
> > Pages with reference count zero will be not be moved to the page
> > list, and truncated pages seem to be handled nicely later on the
> > migration codepath.
> > 
> > A quick search on Iwamoto's test utils shows no sign of truncate(). 
> 
> IIRC, the easiest test method is file overwrite, such as
> 
> 	while true; do
> 		tar zxvf ../some.tar.gz
> 	done
> 
> 
> > It would be nice to add more testcases (such as truncate() 
> > intensive application) to his testsuite.
> 
> And it would be great to have an automated regression test suite.
> I wonder if OSDL's test harness(http://stp.sf.net/) could be used, but
> I had no chance to investigate any further.

I dont think it is usable as it is because the benchmarks are fixed
and you can't have scripts (your own commands) running as far as I 
remember - so its not possible to remove memory regions.

Other than that it should be fine - make a script to add/remove
memory zones and let the benchmarks run.

Cliff, Judith, is that right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
