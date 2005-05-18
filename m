Date: 18 May 2005 18:23:48 +0200
Date: Wed, 18 May 2005 18:23:48 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 1/4] remove direct ref to contig_page_data for x86-64
Message-ID: <20050518162348.GB88141@muc.de>
References: <200505181523.j4IFN7rs026902@snoqualmie.dp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200505181523.j4IFN7rs026902@snoqualmie.dp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Cc: akpm@osdl.org, apw@shadowen.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 18, 2005 at 08:23:07AM -0700, Matt Tolentino wrote:
> 
> This patch pulls out all remaining direct references to 
> contig_page_data from arch/x86-64, thus saving an ifdef
> in one case.  

Looks good, thanks (even as a independent patch from sparsemem)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
