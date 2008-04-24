Date: Thu, 24 Apr 2008 04:08:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Message-ID: <20080424020828.GA7101@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org> <20080423153404.GB16769@wotan.suse.de> <20080423154652.GB29087@one.firstfloor.org> <20080423155338.GF16769@wotan.suse.de> <20080423185223.GE10548@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423185223.GE10548@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 11:52:23AM -0700, Nishanth Aravamudan wrote:
> On 23.04.2008 [17:53:38 +0200], Nick Piggin wrote:
> > > It's not fully compatible. And that is bad.
> > 
> > It is fully compatible because if you don't actually ask for any new
> > option then you don't get it. What you see will be exactly unchanged.
> > If you ask for _only_ 1G pages, then this new scheme is very likely to
> > work with well written applications wheras if you also print out the 2MB
> > legacy values first, then they have little to no chance of working.
> > 
> > Then if you want legacy apps to use 2MB pages, and new ones to use 1G,
> > then you ask for both and get the 2MB column printed in /proc/meminfo
> > (actually it can probably get printed 2nd if you ask for 2MB pages
> > after asking for 1G pages -- that is something I'll fix).
> 
> Yep, the "default hugepagesz" was something I was going to ask about. I
> believe hugepagesz= should function kind of like console= where the
> order matters if specified multiple times for where /dev/console points.
> I agree with you that hugepagesz=XX hugepagesz=YY implies XX is the
> default, and YY is the "other", regardless of their values, and that is
> how they should be presented in meminfo.

OK, that would be fine. I was going to do it the other way and make
2M always come first. However so long as we document as such the
command line parameters, I don't see why we couldn't have this extra
flexibility (and that means I shouldn't have to write any more code ;))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
