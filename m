Date: Sun, 25 May 2008 16:42:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/23] multi size, giant hugetlb support, 1GB for x86, 16GB for powerpc
Message-ID: <20080525144238.GA25747@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080525142317.965503000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Mon, May 26, 2008 at 12:23:17AM +1000, npiggin@suse.de wrote:
> Hi all,
> 
> Given the amount of feedback this has had, and the powerpc patches from Jon,
> I'll send out one more request for review and testing before asking Andrew
> to merge in -mm.
> 
> Patches are against Linus's current git (eb90d81d). I will have to rebase
> to -mm next.
> 
> The patches pass the libhugetlbfs regression test suite here on x86 and
> powerpc (although my G5 can only run 16MB hugepages, so it is less
> interesting...).
> 
> So, review and testing welcome.
> 
> Thanks!
> Nick

Arg, sorry I've got Andi's old suse address on some of these:
quilt mail extracts SOBs and adds them to the cc list which always
gets me :(


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
