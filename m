Subject: Re: 150 nonlinear
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
Content-Type: text/plain
Message-Id: <1098815779.4861.26.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 11:36:19 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andy,

I've been thinking about how we're going to merge up the code that uses
Dave M's nonlinear with your new implementation.

There are two problems that are being solved: having a sparse layout
requiring splitting up mem_map (solved by discontigmem and your
nonlinear), and supporting non-linear phys to virt relationships (Dave
M's implentation which does the mem_map split as well).

I think both Dave M. and I agree that your implementation is the way to
go, mostly because it properly starts the separation of these two
distinct problems.

So, I propose the following: your code should be referred to as
something like CONFIG_SPARSEMEM.  The code supporting non-linear p::v
retains the CONFIG_NONLINEAR name.

Do you think your code is in a place where it's ready for wider testing
on a few more architectures?  In which case, would you like it held in
the -mhp tree while it's waiting to get merged?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
