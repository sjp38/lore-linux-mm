Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0I0HW81019708
	for <linux-mm@kvack.org>; Tue, 17 Jan 2006 19:17:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0I0JfCS174804
	for <linux-mm@kvack.org>; Tue, 17 Jan 2006 17:19:41 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0I0HWk4021790
	for <linux-mm@kvack.org>; Tue, 17 Jan 2006 17:17:32 -0700
Subject: Re: [PATCH/RFC] Shared page tables
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060117235302.GA22451@lnx-holt.americas.sgi.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
	 <20060117235302.GA22451@lnx-holt.americas.sgi.com>
Content-Type: text/plain
Date: Tue, 17 Jan 2006 16:17:30 -0800
Message-Id: <1137543450.27951.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-01-17 at 17:53 -0600, Robin Holt wrote:
> This appears to work on ia64 with the attached patch.  Could you
> send me any test application you think would be helpful for me
> to verify it is operating correctly?  I could not get the PTSHARE_PUD
> to compile.  I put _NO_ effort into it.  I found the following line
> was invalid and quit trying.
...
> +config PTSHARE
> +	bool "Share page tables"
> +	default y
> +	help
> +	  Turn on sharing of page tables between processes for large shared
> +	  memory regions.
...

These are probably best put in mm/Kconfig, especially if you're going to
have verbatim copies in each architecture.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
