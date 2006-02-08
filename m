From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [ck] [PATCH] mm: implement swap prefetching v21
Date: Wed, 8 Feb 2006 14:49:20 +1100
References: <200602071028.30721.kernel@kolivas.org> <20060206163842.7ff70c49.akpm@osdl.org> <200602081429.11823.kernel@kolivas.org>
In-Reply-To: <200602081429.11823.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602081449.20767.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ck@vds.kolivas.org
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Feb 2006 02:29 pm, Con Kolivas wrote:
> Ok here is a rewrite incorporating many of the suggested changes by Andrew
> and Nick (thanks both for comments). The numa and cpuset issues Nick
> brought up I have not tackled (yet?)

> +/* sysctl - enable/disable swap prefetching */
> +int swap_prefetch __read_mostly = 1;

Err I seem to have forgotten to actually use the enable/disable tunable now. 
Patch works fine otherwise.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
