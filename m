Date: Mon, 14 Oct 2002 18:08:56 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [Lse-tech] Re: [rfc][patch] Memory Binding API v0.3 2.5.41
Message-ID: <2007503407.1034618934@[10.10.2.3]>
In-Reply-To: <1034643354.19094.149.camel@cog>
References: <1034643354.19094.149.camel@cog>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: john stultz <johnstul@us.ibm.com>, Matt <colpatch@us.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE Tech <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

>> Also, right now, memblks map to nodes in a straightforward manner (1-1 
>> on NUMA-Q, the only architecture that has defined them).  It will likely 
>> look the same on most architectures, too.
> 
> Just an FYI: I believe the x440 breaks this assumption. 
> 
> There are 2 chunks on the first CEC. The current discontig patch for it
> has to drop the second chunk (anything over 3.5G on the first CEC) in
> order to work w/ the existing code. However, that will probably need to
> be addressed at some point, so be aware that this might affect you as
> well. 

No, the NUMA code in the kernel doesn't support that anyway.
You have to use zholes_size, and waste some struct pages,
or config_nonlinear. Either way you get 1 memblk.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
