Message-ID: <417EA06B.5040609@kolumbus.fi>
Date: Tue, 26 Oct 2004 22:07:23 +0300
From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: 150 nonlinear
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org> <1098815779.4861.26.camel@localhost>
In-Reply-To: <1098815779.4861.26.camel@localhost>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>Hi Andy,
>
>I've been thinking about how we're going to merge up the code that uses
>Dave M's nonlinear with your new implementation.
>
>There are two problems that are being solved: having a sparse layout
>requiring splitting up mem_map (solved by discontigmem and your
>nonlinear), and supporting non-linear phys to virt relationships (Dave
>M's implentation which does the mem_map split as well).
>
>I think both Dave M. and I agree that your implementation is the way to
>go, mostly because it properly starts the separation of these two
>distinct problems.
>
>So, I propose the following: your code should be referred to as
>something like CONFIG_SPARSEMEM.  The code supporting non-linear p::v
>retains the CONFIG_NONLINEAR name.
>
>Do you think your code is in a place where it's ready for wider testing
>on a few more architectures?  In which case, would you like it held in
>the -mhp tree while it's waiting to get merged?  
>
>-- Dave
>
>  
>
What do you consider as Dave M's nonlinear?

--Mika

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
