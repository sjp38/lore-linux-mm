Date: Fri, 2 Mar 2007 10:02:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302100257.fd0d44a8.akpm@linux-foundation.org>
In-Reply-To: <20070302173527.GA7280@linux.intel.com>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
	<45E7835A.8000908@in.ibm.com>
	<Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
	<20070301195943.8ceb221a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
	<20070302162023.GA4691@linux.intel.com>
	<20070302090753.b06ed267.akpm@linux-foundation.org>
	<20070302173527.GA7280@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007 09:35:27 -0800
Mark Gross <mgross@linux.intel.com> wrote:

> > 
> > Will it be possible to just power the DIMMs off?  I don't see much point in
> > some half-power non-destructive mode.
> 
> I think so, but need to double check with the HW folks.
> 
> Technically, the dims could be powered off, and put into 2 different low
> power non-destructive states.  (standby and suspend), but putting them
> in a low power non-destructive mode has much less latency and provides
> good bang for the buck or LOC change needed to make work.
> 
> Which lower power mode an application chooses will depend on latency
> tolerances of the app.  For the POC activities we are looking at we are
> targeting the lower latency option, but that doesn't lock out folks from
> trying to do something with the other options.
> 

If we don't evacuate all live data from all of the DIMM, we'll never be
able to power the thing down in many situations.

Given that we _have_ emptied the DIMM, we can just turn it off.  And
refilling it will be slow - often just disk speed.

So I don't see a useful use-case for non-destructive states.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
