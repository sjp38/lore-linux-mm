Received: from cthulhu.engr.sgi.com (cthulhu.engr.sgi.com [192.26.80.2])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id iAD12hFK026384
	for <linux-mm@kvack.org>; Fri, 12 Nov 2004 17:02:45 -0800
Message-ID: <41954B1F.5060900@sgi.com>
Date: Fri, 12 Nov 2004 17:45:35 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: removing mm->rss and mm->anon_rss from kernel?
References: <200411081547.iA8FlH90124208@ben.americas.sgi.com> <41919EA5.7030200@yahoo.com.au>
In-Reply-To: <41919EA5.7030200@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Russ Anderson <rja@sgi.com>, Matthew Wilcox <matthew@wil.cx>, "Martin J. Bligh" <mbligh@aracnet.com>, Christoph Lameter <clameter@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> 
> Also, are you using 2.6 kernels on these 512 CPU systems? or are your
> 2.4 kernels still holding together at that many CPUs?

Nick,

My response to your email was (unfortunately) overly broad.  While the
NASA 512P systems are running a kernel based on 2.4.x, SLES 9, which is 
2.6.5-based, has been certified on a 64p SGI Altix
system (cf. http://developer.novell.com/yes/78980.htm).

So it is possible to buy a supported 2.6 kernel from SuSE that will run your
(up to) 64P Altix.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
