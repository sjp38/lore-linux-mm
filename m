Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E1A8E6B01FA
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:18:42 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH -mm] slub: document setting min order with debug_guardpage_minorder > 0
Date: Tue, 13 Dec 2011 00:21:41 +0100
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com> <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com> <20111212145948.GA2380@redhat.com>
In-Reply-To: <20111212145948.GA2380@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201112130021.41429.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>

On Monday, December 12, 2011, Stanislaw Gruszka wrote:
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---
> English is hard (definitely harder than C language :-), so please correct
> me, if I wrote something wrong.
> 
>  Documentation/ABI/testing/sysfs-kernel-slab |    4 +++-
>  Documentation/vm/slub.txt                   |    4 +++-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
> index 8b093f8..d84ca80 100644
> --- a/Documentation/ABI/testing/sysfs-kernel-slab
> +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> @@ -345,7 +345,9 @@ Description:
>  		allocated.  It is writable and can be changed to increase the
>  		number of objects per slab.  If a slab cannot be allocated
>  		because of fragmentation, SLUB will retry with the minimum order
> -		possible depending on its characteristics.
> +		possible depending on its characteristics. 

Added trailing whitespace (please remove).

> +		When debug_guardpage_minorder > 0 parameter is specified, the
> +		minimum possible order is used and cannot be changed.

Well, I'm not sure what you wanted to say, actually?  How does one change
debug_guardpage_minorder (or specify it), for example?  Is it a kernel
command-line switch?

Also I'm not sure what "cannot be changed" is supposed to mean.  Does it
mean that /sys/cache/slab/cache/order has no effect in that case?

>  
>  What:		/sys/kernel/slab/cache/order_fallback
>  Date:		April 2008
> diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
> index f464f47..dbf02ad 100644
> --- a/Documentation/vm/slub.txt
> +++ b/Documentation/vm/slub.txt
> @@ -131,7 +131,9 @@ slub_min_objects.
>  slub_max_order specified the order at which slub_min_objects should no
>  longer be checked. This is useful to avoid SLUB trying to generate
>  super large order pages to fit slub_min_objects of a slab cache with
> -large object sizes into one high order page.
> +large object sizes into one high order page. Setting parameter
> +debug_guardpage_minorder > 0 forces setting slub_max_order to 0, what
> +cause minimum possible order of slabs allocation.
>  
>  SLUB Debug output
>  -----------------
> 

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
