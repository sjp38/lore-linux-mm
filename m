Date: Fri, 09 May 2003 12:49:26 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.69-mm3
Message-ID: <49830000.1052509765@[10.10.2.4]>
In-Reply-To: <20030509141012.GD2059@in.ibm.com>
References: <20030508013958.157b27b7.akpm@digeo.com> <20030509141012.GD2059@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dipankar@in.ibm.com, Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I am wondering what we should do with this patch. The RCU stats display
> the #s of RCU requests and actual updates on each CPU. On a normal system
> they don't mean much to a sysadmin, so I am not sure if it is the right
> thing to include this feature. OTOH, it is extremely useful to detect
> potential memory leaks happening due to, say a CPU looping in
> kernel (and RCU not happening consequently). Will a CONFIG_RCU_DEBUG
> make it more palatable for mainline ?

I'd find that useful - if it has a measurable overhead. If not, just leave
it on all the time ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
