From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [PATCH] don't pass mem_map into init functions
Date: Wed, 28 Jul 2004 18:33:55 -0700
References: <1091048123.2871.435.camel@nighthawk> <200407281539.40049.jbarnes@engr.sgi.com> <1091056702.2871.617.camel@nighthawk>
In-Reply-To: <1091056702.2871.617.camel@nighthawk>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200407281833.55574.jbarnes@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm <linux-mm@kvack.org>, LSE <lse-tech@lists.sourceforge.net>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, davidm@hpl.hp.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Wednesday, July 28, 2004 4:18 pm, Dave Hansen wrote:
> On Wed, 2004-07-28 at 15:39, Jesse Barnes wrote:
> > You're missing this little bit from your patchset.  Cc'ing Tony and
> > David.
>
> Thanks for finding that.  That appears to be an ia64-ism, so I think the
> rest of the patch is OK.

Well, it booted anyway :).  I didn't check to see if any other arches had 
their own memmap_init routines though, I'm assuming you already covered 
those.

Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
