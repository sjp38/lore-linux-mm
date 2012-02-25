Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 33B8E6B002C
	for <linux-mm@kvack.org>; Sat, 25 Feb 2012 18:10:27 -0500 (EST)
Date: Sat, 25 Feb 2012 23:10:25 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: avoid EINVAL if user input is valid
Message-ID: <20120225231025.GA20598@dcvr.yhbt.net>
References: <20120225022710.GA29455@dcvr.yhbt.net>
 <4F496715.7070005@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4F496715.7070005@draigBrady.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?Q?P=C3=A1draig?= Brady <P@draigBrady.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

PA!draig Brady <P@draigBrady.com> wrote:
> On 02/25/2012 02:27 AM, Eric Wong wrote:
> > +		force_page_cache_readahead(mapping, file, start_index, nrpages);
> >  		break;
> 
> This whole patch makes sense to me.
> The above chunk might cause confusion in future,
> if people wonder for a moment why the return is ignored.
> Should you use cast with (void) like this to be explicit?
> 
> (void) force_page_cache_readahead(...);

I considered this, too[1].  However I checked for existing usages of
force_page_cache_readahead() noticed they just ignore the return value
like I did in my patch, so I followed existing convention for this
function.   I didn't find any suggestion in Documentation/CodingStyle
for this.

Thanks for looking at this.

[1] - it's what I normally do in my own projects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
