Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B2A676B0055
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 05:31:04 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n8M9UfCT092062
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 09:30:46 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8M9UPEf667792
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:30:31 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8M9UNql009329
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 10:30:25 +0100
Date: Tue, 22 Sep 2009 11:30:23 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 3/3] slqb: Allow SLQB to be used on PPC
Message-ID: <20090922093023.GA22441@osiris.boeblingen.de.ibm.com>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
 <1253549426-917-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1253549426-917-4-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 21, 2009 at 05:10:26PM +0100, Mel Gorman wrote:
> SLQB was disabled on PPC as it would stab itself in the face when running
> on machines with CPUs on memoryless nodes. As those configurations should
> now work, allow SLQB to be configured again on PPC.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  init/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/init/Kconfig b/init/Kconfig
> index adc10ab..8f55fde 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -1033,7 +1033,7 @@ config SLUB
> 
>  config SLQB
>  	bool "SLQB (Queued allocator)"
> -	depends on !PPC && !S390
> +	depends on !S390

You can remove S390 from the list independently from this patch set.
As already mentioned SLQB works again on s390 and whatever caused the
bug I reported a few weeks back is gone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
