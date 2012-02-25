Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9D22F6B002C
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 17:56:23 -0500 (EST)
Message-ID: <4F496715.7070005@draigBrady.com>
Date: Sat, 25 Feb 2012 22:56:21 +0000
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fadvise: avoid EINVAL if user input is valid
References: <20120225022710.GA29455@dcvr.yhbt.net>
In-Reply-To: <20120225022710.GA29455@dcvr.yhbt.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/25/2012 02:27 AM, Eric Wong wrote:
> The kernel is not required to act on fadvise, so fail silently
> and ignore advice as long as it has a valid descriptor and
> parameters.
> 

> @@ -106,12 +105,8 @@ SYSCALL_DEFINE(fadvise64_64)(int fd, loff_t offset, loff_t len, int advice)
>  		nrpages = end_index - start_index + 1;
>  		if (!nrpages)
>  			nrpages = ~0UL;
> -		
> -		ret = force_page_cache_readahead(mapping, file,
> -				start_index,
> -				nrpages);
> -		if (ret > 0)
> -			ret = 0;
> +
> +		force_page_cache_readahead(mapping, file, start_index, nrpages);
>  		break;

This whole patch makes sense to me.
The above chunk might cause confusion in future,
if people wonder for a moment why the return is ignored.
Should you use cast with (void) like this to be explicit?

(void) force_page_cache_readahead(...);

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
