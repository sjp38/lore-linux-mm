Subject: Re: [Lse-tech] Re: [rfc][patch] Memory Binding API v0.3 2.5.41
From: john stultz <johnstul@us.ibm.com>
In-Reply-To: <3DAB6385.9000207@us.ibm.com>
References: <3DAB5DF2.5000002@us.ibm.com>
	<2004595005.1034616026@[10.10.2.3]>  <3DAB6385.9000207@us.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 14 Oct 2002 17:55:53 -0700
Message-Id: <1034643354.19094.149.camel@cog>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt <colpatch@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE Tech <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2002-10-14 at 17:38, Matthew Dobson wrote:
> Also, right now, memblks map to nodes in a straightforward manner (1-1 
> on NUMA-Q, the only architecture that has defined them).  It will likely 
> look the same on most architectures, too.

Just an FYI: I believe the x440 breaks this assumption. 

There are 2 chunks on the first CEC. The current discontig patch for it
has to drop the second chunk (anything over 3.5G on the first CEC) in
order to work w/ the existing code. However, that will probably need to
be addressed at some point, so be aware that this might affect you as
well. 

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
