Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA27988
	for <linux-mm@kvack.org>; Tue, 17 Sep 2002 13:04:48 -0700 (PDT)
Message-ID: <3D878ADD.62BA2DF3@digeo.com>
Date: Tue, 17 Sep 2002 13:04:45 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Examining the Performance and Cost of Revesemaps on 2.5.26 Under
 Heavy DBWorkload
References: <OF6165D951.694A9B41-ON85256C36.00684F02@pok.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Wong <wpeter@us.ibm.com>
Cc: linux-mm@kvack.org, lse-tech@lists.sourceforge.net, riel@nl.linux.org, mjbligh@us.ibm.com, wli@holomorphy.com, dmccr@us.ibm.comgh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Peter Wong wrote:
> 
> ...
>      My previous note (Sept. 10, 2002) indicated that the memory
> consumption for rmaps under 2.5.32 using "readv" is about 223 MB.

Thanks, Peter.

That's a ton of memory.  Where do we stand wrt getting these
applications to use large-tlb pages?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
