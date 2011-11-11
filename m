Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA8E6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 01:50:08 -0500 (EST)
Date: Fri, 11 Nov 2011 07:50:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/5]thp: improve the error code path
Message-ID: <20111111065003.GO5075@redhat.com>
References: <1319593680.22361.145.camel@sli10-conroe>
 <1320643049.22361.204.camel@sli10-conroe>
 <20111110021853.GQ5075@redhat.com>
 <1320892395.22361.229.camel@sli10-conroe>
 <alpine.DEB.2.00.1111091828500.32414@chino.kir.corp.google.com>
 <20111110030646.GT5075@redhat.com>
 <alpine.DEB.2.00.1111092039110.27280@chino.kir.corp.google.com>
 <1320904609.22361.239.camel@sli10-conroe>
 <20111110141412.GW5075@redhat.com>
 <1320993217.22361.253.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1320993217.22361.253.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, Nov 11, 2011 at 02:33:37PM +0800, Shaohua Li wrote:
> Improve the error code path. Delete unnecessary sysfs file for example.
> Also remove the #ifdef xxx to make code better.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> ---
>  mm/huge_memory.c |   71 ++++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 50 insertions(+), 21 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
