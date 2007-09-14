Subject: Re: [PATCH 1/4] hugetlb: search harder for memory in
	alloc_fresh_huge_page()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709141041390.15683@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com>
	 <20070914172638.GT24941@us.ibm.com>
	 <Pine.LNX.4.64.0709141041390.15683@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 14:20:52 -0400
Message-Id: <1189794052.5315.48.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, agl@us.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 10:43 -0700, Christoph Lameter wrote:
> On Fri, 14 Sep 2007, Nishanth Aravamudan wrote:
> 
> > Christoph, Lee, ping? I haven't heard any response on these patches this
> > time around. Would it be acceptable to ask Andrew to pick them up for
> > the next -mm?
> 
> I am sorry but there is some churn already going on with other core memory 
> management patches. Could we hold this off until the dust settles on those 
> and then rebase?

Hi, Nish:

Sorry not to have responded sooner.  I have been building your patches
atop my memory policy changes, and I did test them on my platform.  The
seem to work.  There was one conflict with my memory policy reference
counting fix, but that was easy to resolve.  I'd have no problem with
these going in.  They probably will conflict with Mel's patches, but
again this should be easy to resolve.

Earlier Christoph said he didn't think Mel's 'one zonelist' series would
make .24.  I think that's still under discussion, but if Mel's patches
don't make .24, then I think these should go in.  So, I'll go ahead and
ACK them as they are, against 23-rc4-mm1.  Still, I think it would a
good idea for you to grab Mel's patches check out the conflicts.
Whether to rebase Mel's atop yours or vice versa is a more difficult
question.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
