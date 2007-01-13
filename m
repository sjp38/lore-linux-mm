Date: Fri, 12 Jan 2007 23:42:42 -0800
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
Message-ID: <20070113074242.GB4234@localhost.localdomain>
References: <20070112160104.GA5766@localhost.localdomain> <Pine.LNX.4.64.0701121137430.2306@schroedinger.engr.sgi.com> <20070112214021.GA4300@localhost.localdomain> <Pine.LNX.4.64.0701121341320.3087@schroedinger.engr.sgi.com> <20070113010039.GA8465@localhost.localdomain> <20070112171116.a8f62ecb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070112171116.a8f62ecb.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Fri, Jan 12, 2007 at 05:11:16PM -0800, Andrew Morton wrote:
> On Fri, 12 Jan 2007 17:00:39 -0800
> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
> 
> > But is
> > lru_lock an issue is another question.
> 
> I doubt it, although there might be changes we can make in there to
> work around it.
> 
> <mentions PAGEVEC_SIZE again>

I tested with PAGEVEC_SIZE define to 62 and 126 -- no difference.  I still
notice the atrociously high spin times.

Thanks,
Kiran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
