Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id A61FF6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 14:40:03 -0400 (EDT)
Date: Fri, 2 Nov 2012 14:39:50 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/5] staging: zcache2+ramster: enable zcache2 to be
 built/loaded as a module
Message-ID: <20121102183950.GD30100@konrad-lan.dumpdata.com>
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
 <1351696074-29362-4-git-send-email-dan.magenheimer@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351696074-29362-4-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, minchan@kernel.org, fschmaus@gmail.com, andor.damm@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

On Wed, Oct 31, 2012 at 08:07:52AM -0700, Dan Magenheimer wrote:
> Allow zcache2 to be built/loaded as a module.  Note runtime dependency
> disallows loading if cleancache/frontswap lazy initialization patches
> are not present.  Zsmalloc support has not yet been merged into zcache2
> but, once merged, could now easily be selected via a module_param.
> 
> If built-in (not built as a module), the original mechanism of enabling via
> a kernel boot parameter is retained, but this should be considered deprecated.
> 
> Note that module unload is explicitly not yet supported.

I had an issue putting it on v3.7-rc3 with the Kconfig. Not sure why
as it looks exactly the same.

The patch looks good, however..

> @@ -1812,9 +1846,28 @@ static int __init zcache_init(void)
>  	}
>  	if (ramster_enabled)
>  		ramster_init(!disable_cleancache, !disable_frontswap,
> -				frontswap_has_exclusive_gets);
> +				frontswap_has_exclusive_gets,
> +				!disable_frontswap_selfshrink);
>  out:
>  	return ret;
>  }

.. ramster_init change is in the next patch. So it looks like the
patch order is a bit mismatched.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
