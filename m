Subject: Re: Active Memory Defragmentation: Our implementation & problems
Message-ID: <OFE7103176.29D4436D-ON86256E30.006E41D8@raytheon.com>
From: Mark_H_Johnson@raytheon.com
Date: Wed, 4 Feb 2004 14:12:17 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Timothy Miller <miller@techsource.com>, owner-linux-mm@kvack.org, Alok Mooley <rangdi@yahoo.com>
List-ID: <linux-mm.kvack.org>




Richard B. Johnson wrote:

>Eventually you
>get to the fact that even contiguous physical RAM doesn't
>have to be contiguous and, in fact, with modern controllers
>it's quite unlikely that it is. It's a sack of bits that
>are uniquely addressable.

Yes and no. We are using a shared memory interface on a cluster that allows
us to map up to 512 Mbytes of memory from another machine. There are 16k
address translation table (ATT) entries in the card, so we're allocating
32K chunks of memory per ATT. We are using the bigphysarea patch for the
driver (in 2.4 kernels) only because the driver can't reliably get the
chunks of RAM it is asking for. We can continue to operate the way we've
been doing or get a mechanism to defragment physical RAM so the driver can
continue to work a week after we rebooted the machine.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
