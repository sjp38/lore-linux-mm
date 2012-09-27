Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 05A126B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 16:06:59 -0400 (EDT)
Date: Thu, 27 Sep 2012 23:06:47 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm/mpol: Make MPOL_LOCAL a real policy
Message-ID: <20120927200647.GU13767@mwanda>
References: <20120521133838.GA12116@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120521133838.GA12116@elgon.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org

Whatever happened with this?   It's a small read past the end of the
array, but probably it should be fixed.

regards,
dan carpenter

On Mon, May 21, 2012 at 04:38:39PM +0300, Dan Carpenter wrote:
> Hello Peter Zijlstra,
> 
> The patch 03ed7b538ca0: "mm/mpol: Make MPOL_LOCAL a real policy" from 
> Mar 19, 2012, leads to the following warning:
> mm/mempolicy.c:2591 mpol_parse_str()
> 	 error: buffer overflow 'policy_modes' 5 <= 5
> 
> mm/mempolicy.c
>   2590          for (mode = 0; mode < MPOL_MAX; mode++) {
>   2591                  if (!strcmp(str, policy_modes[mode])) {
>   2592                          break;
>   2593                  }
>   2594          }
> 
> The problem is that MPOL_NOOP is not defined in policy_modes[] so we
> search past the end of the array.
> 
> regards,
> dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
