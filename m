Subject: Re: [PATCH] don't pass mem_map into init functions
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <200407281539.40049.jbarnes@engr.sgi.com>
References: <1091048123.2871.435.camel@nighthawk>
	 <200407281501.19181.jbarnes@engr.sgi.com>
	 <1091053187.2871.526.camel@nighthawk>
	 <200407281539.40049.jbarnes@engr.sgi.com>
Content-Type: text/plain
Message-Id: <1091056702.2871.617.camel@nighthawk>
Mime-Version: 1.0
Date: Wed, 28 Jul 2004 16:18:22 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm <linux-mm@kvack.org>, LSE <lse-tech@lists.sourceforge.net>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, davidm@hpl.hp.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 2004-07-28 at 15:39, Jesse Barnes wrote:
> You're missing this little bit from your patchset.  Cc'ing Tony and David.

Thanks for finding that.  That appears to be an ia64-ism, so I think the
rest of the patch is OK.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
