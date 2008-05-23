Date: Sat, 24 May 2008 00:49:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 07/18] hugetlbfs: per mount hstates
Message-ID: <20080523224958.GB3144@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.378900000@nick.local0.net> <20080425180933.GF9680@us.ibm.com> <20080523052425.GG13071@wotan.suse.de> <20080523203444.GD23924@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523203444.GD23924@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, May 23, 2008 at 01:34:44PM -0700, Nishanth Aravamudan wrote:
> On 23.05.2008 [07:24:25 +0200], Nick Piggin wrote:
> > On Fri, Apr 25, 2008 at 11:09:33AM -0700, Nishanth Aravamudan wrote:
> > True, but it is quite a long process and it is nice to have it working
> > each step of the way in small steps... I think the overall way Andi's
> > done the patchset is quite nice.
> 
> Yeah, I'm sorry if my review came across as overly critical at the time.
> I really am impressed with the amount of change and how it was
> presented. But, in all honesty, given that I have not seen many patches
> from Andi nor yourself for hugetlbfs code in the past few years, nor do
> I expect to see many in the future, I was trying to keep the code as
> sensible as possible for those of us that do interact with it regularly
> (and its userspace interface, especially !SHM_HUGETLB).

Yes it's important you're happy with it for that reason. So I have made
a lot of changes you suggested, and other things if you feel strongly
about could be changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
