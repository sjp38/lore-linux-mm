Message-ID: <4180D30C.6020707@shadowen.org>
Date: Thu, 28 Oct 2004 12:07:56 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 150 nonlinear
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org> <1098815779.4861.26.camel@localhost>
In-Reply-To: <1098815779.4861.26.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> I've been thinking about how we're going to merge up the code that uses
> Dave M's nonlinear with your new implementation.
> 
> There are two problems that are being solved: having a sparse layout
> requiring splitting up mem_map (solved by discontigmem and your
> nonlinear), and supporting non-linear phys to virt relationships (Dave
> M's implentation which does the mem_map split as well).
> 
> I think both Dave M. and I agree that your implementation is the way to
> go, mostly because it properly starts the separation of these two
> distinct problems.
> 
> So, I propose the following: your code should be referred to as
> something like CONFIG_SPARSEMEM.  The code supporting non-linear p::v
> retains the CONFIG_NONLINEAR name.
> 
> Do you think your code is in a place where it's ready for wider testing
> on a few more architectures?  In which case, would you like it held in
> the -mhp tree while it's waiting to get merged?  

Ok.  Meant to get back to you sooner, trouble getting test runs through 
on the new version.  Anyhow, yes thats fine with me.  I'll send out a 
new version here today renamed to CONFIG_SPARSEMEM.  This also has a few 
fixes as a result of futher testing.  -mhp seems as good a place as any 
for the moment.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
