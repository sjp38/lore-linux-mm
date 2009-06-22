Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 997306B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 10:30:52 -0400 (EDT)
Message-ID: <4A3F95A6.5040503@nortel.com>
Date: Mon, 22 Jun 2009 08:31:02 -0600
From: "Chris Friesen" <cfriesen@nortel.com>
MIME-Version: 1.0
Subject: Re: [RFC] transcendent memory for Linux
References: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:

> What if there was a class of memory that is of unknown
> and dynamically variable size, is addressable only indirectly
> by the kernel, can be configured either as persistent or
> as "ephemeral" (meaning it will be around for awhile, but
> might disappear without warning), and is still fast enough
> to be synchronously accessible?
> 
> We call this latter class "transcendent memory"

While true that this memory is "exceeding usual limits", the more
important criteria is that it may disappear.

It might be clearer to just call it "ephemeral memory".

There is going to be some overhead due to the extra copying, and at
times there could be two copies of data in memory.  It seems possible
that certain apps right a the borderline could end up running slower
because they can't fit in the regular+ephemeral memory due to the
duplication, while the same amount of memory used normally could have
been sufficient.

I suspect trying to optimize management of this could be difficult.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
