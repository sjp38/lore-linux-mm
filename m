Subject: Re: [PATCH] don't pass mem_map into init functions
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1091056702.2871.617.camel@nighthawk>
References: <1091048123.2871.435.camel@nighthawk>
	 <200407281501.19181.jbarnes@engr.sgi.com>
	 <1091053187.2871.526.camel@nighthawk>
	 <200407281539.40049.jbarnes@engr.sgi.com>
	 <1091056702.2871.617.camel@nighthawk>
Content-Type: text/plain
Message-Id: <1091142640.23502.118.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 29 Jul 2004 16:10:40 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm <linux-mm@kvack.org>, LSE <lse-tech@lists.sourceforge.net>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, davidm@hpl.hp.com, tony.luck@intel.com, Jesse Barnes <jbarnes@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Martin,

I think that zone init code is yours from the initial CONFIG_NUMA port
and the kva remap code.  Do you think it's ready to go upstream?  If so,
do you want to send it, or should I?

It works on the NUMAQ, on regular SMP and Jesse Barnes tested it too.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
