From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070404040232.2FEF6DDEBA@ozlabs.org> 
References: <20070404040232.2FEF6DDEBA@ozlabs.org> 
Subject: Re: [PATCH 12/14] get_unmapped_area handles MAP_FIXED in /dev/mem (nommu) 
Date: Wed, 04 Apr 2007 11:31:09 +0100
Message-ID: <23349.1175682669@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> +	if (flags & MAP_FIXED)
> +		if ((addr >> PAGE_SHIFT) != pgoff)
> +			return (unsigned long) -EINVAL;

Again... in NOMMU-mode there is no MAP_FIXED - it's rejected before we get
this far.

> -	return pgoff;
> +	return pgoff << PAGE_SHIFT;

That, however, does appear to be a genuine bugfix.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
