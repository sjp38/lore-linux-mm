Date: Thu, 13 Apr 2006 10:47:20 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH 0/7] [RFC] Sizing zones and holes in an architecture independent manner V2
Message-ID: <20060413174720.GA15183@agluck-lia64.sc.intel.com>
References: <20060412232036.18862.84118.sendpatchset@skynet> <20060413095207.GA4047@skynet.ie> <20060413171942.GA15047@agluck-lia64.sc.intel.com> <20060413173008.GA19402@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060413173008.GA19402@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: davej@codemonkey.org.uk, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Double counted a hole here, then went downhill. Does the following fix
> it?

Yes, that boots.  What's more the counts of pages in DMA/Normal
zone match the kernel w/o your patches too.  So for tiger_defconfig
you've now exactly matched the old behaivour.

I'll try to test generic and sparse kernels later, but I have to
look at another issue now.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
