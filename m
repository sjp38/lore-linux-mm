Date: Sun, 21 Dec 2003 17:21:26 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: load control demotion/promotion policy
Message-ID: <20031222012126.GC11655@holomorphy.com>
References: <Pine.LNX.4.44.0312202125580.26393-100000@chimarrao.boston.redhat.com> <20031221235541.GA22896@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031221235541.GA22896@k3.hellgate.ch>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Luethi <rl@hellgate.ch>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Sat, 20 Dec 2003 21:33:34 -0500, Rik van Riel wrote:
>> I've got an idea for a load control / memory scheduling
>> policy that is inspired by the following requirements
>> and data points:

On Mon, Dec 22, 2003 at 12:55:42AM +0100, Roger Luethi wrote:
> It is my understanding that wli is interested in load control because
> he knows this Russian guy who puts an insane load on his box. Do you
> have friends in Russia as well? Isn't there _anybody_ interested in
> the fact that 2.6 performance completely breaks down under a light
> overload where 2.4 doesn't and where load control would be more of a
> problem than a solution? Heck, I even showed that you don't have to give
> up physical scanning to get most of the pageout performance back! Oh,
> and btw: Did I overlook this problem on akpm's should/must fix lists,
> or is it missing for a reason?

Obviously, the simple regressions should be corrected first. We're not
interested in programming them ourselves because as far as we know,
you've already written the fixes. It would be premature to do
measurements before your fixes are in place.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
