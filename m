From: Jesse Barnes <jbarnes@engr.sgi.com>
Subject: Re: [PATCH] don't pass mem_map into init functions
Date: Wed, 28 Jul 2004 14:58:37 -0700
References: <1091048123.2871.435.camel@nighthawk>
In-Reply-To: <1091048123.2871.435.camel@nighthawk>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200407281458.37344.jbarnes@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-mm <linux-mm@kvack.org>, LSE <lse-tech@lists.sourceforge.net>, Anton Blanchard <anton@samba.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday, July 28, 2004 1:55 pm, Dave Hansen wrote:
> Compile tested on SMP x86 and NUMAQ.  I plan to give it a run on ppc64
> in a bit.  I'd appreciate if one of the ia64 guys could make sure it's
> OK for them as well.

It *looks* ok.  I'll give it a whirl to make sure.

Jesse
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
