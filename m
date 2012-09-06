Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 380446B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 12:27:52 -0400 (EDT)
Received: by iagk10 with SMTP id k10so2765872iag.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 09:27:51 -0700 (PDT)
Date: Thu, 6 Sep 2012 09:25:15 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [patch] staging: ramster: fix range checks in
 zcache_autocreate_pool()
Message-ID: <20120906162515.GA423@kroah.com>
References: <20120906124020.GA28946@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120906124020.GA28946@elgon.mountain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: devel@driverdev.osuosl.org, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, kernel-janitors@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, Sep 06, 2012 at 03:40:20PM +0300, Dan Carpenter wrote:
> If "pool_id" is negative then it leads to a read before the start of the
> array.  If "cli_id" is out of bounds then it leads to a NULL dereference
> of "cli".  GCC would have warned about that bug except that we
> initialized the warning message away.
> 
> Also it's better to put the parameter names into the function
> declaration in the .h file.  It serves as a kind of documentation.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> BTW, This file has a ton of GCC warnings.  This function returns -1
> on error which is a nonsense return code but the return value is not
> checked anyway.  *Grumble*.

I agree, it's very messy.  Dan Magenheimer should have known better, and
he better be sending me a patch soon to remove these warnings (hint...)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
