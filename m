Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1OKnh0D612082
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 15:49:43 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1OKngXW159606
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 13:49:43 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1OKngLO023502
	for <linux-mm@kvack.org>; Thu, 24 Feb 2005 13:49:42 -0700
From: James Cleverdon <jamesclv@us.ibm.com>
Reply-To: jamesclv@us.ibm.com
Subject: Re: [PATCH 5/5] SRAT cleanup: make calculations and indenting level more sane
Date: Thu, 24 Feb 2005 12:49:54 -0800
References: <E1D4Mns-0007DT-00@kernel.beaverton.ibm.com> <1109273434.9817.1950.camel@knk> <1109274881.7244.87.camel@localhost>
In-Reply-To: <1109274881.7244.87.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200502241249.54796.jamesclv@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: keith <kmannth@us.ibm.com>, linux-mm <linux-mm@kvack.org>, matt dobson <colpatch@us.ibm.com>, Mike Kravetz <kravetz@us.ibm.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Anton Blanchard <anton@samba.org>, Yasunori Goto <ygoto@us.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

No, I don't think we could rely on that.  Our BIOS did ascending 
addresses, but I don't recall that being spelled out in the ACPI spec.

Of course, there's a new ACPI spec out.  Maybe it makes it a 
requirement.  I'd take a look, but I can't afford the loss of sanity 
caused by gazing on the dread visage of ACPI 3.0.   ;^)


On Thursday 24 February 2005 11:54 am, Dave Hansen wrote:
> On Thu, 2005-02-24 at 11:30 -0800, keith wrote:
> > Why not take it one step further??  Something like the attached
> > patch. There is no reason to loop over the nodes as the srat
> > entries contain node info and we can use the the new
> > node_has_online_mem.
>
> You took away my function :)
>
> Seriously, though, that does look better.  Although, I still wouldn't
> mind seeing it kept broken out in another function like my patch.
>
> > This booted ok on my hot-add enabled 8-way.
> >  I am not %100 sure it is ok to make the assumption that the memory
> > is always reported linearly but that is the assumption of the
> > previous code so it must be for all know examples.
>
> Hey James, didn't we decide at some point that the SRAT could only
> have chunks with ascending addresses?
>
> -- Dave

-- 
James Cleverdon
IBM LTC (xSeries Linux Solutions)
{jamesclv(Unix, preferred), cleverdj(Notes)} at us dot ibm dot comm
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
