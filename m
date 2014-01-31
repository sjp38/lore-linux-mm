Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 98E386B0037
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 05:32:34 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so1002098eaj.3
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 02:32:34 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id a9si16970127eem.132.2014.01.31.02.32.32
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 02:32:33 -0800 (PST)
Date: Fri, 31 Jan 2014 11:32:32 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v4 1/2] mm: add kstrimdup function
Message-ID: <20140131103232.GB1534@amd.pavel.ucw.cz>
References: <1391039304-3172-1-git-send-email-sebastian.capella@linaro.org>
 <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391039304-3172-2-git-send-email-sebastian.capella@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Wed 2014-01-29 15:48:23, Sebastian Capella wrote:
> kstrimdup will duplicate and trim spaces from the passed in
> null terminated string.  This is useful for strings coming from
> sysfs that often include trailing whitespace due to user input.

Is it good idea? I mean "\n\n/foo bar baz" is valid filename in
unix. This is kernel interface, it is not meant to be too user
friendly...
									Pavel


> +char *kstrimdup(const char *s, gfp_t gfp)
> +{
> +	char *ret = kstrdup(skip_spaces(s), gfp);
> +
> +	if (ret)
> +		strim(ret);
> +	return ret;
> +}
> +EXPORT_SYMBOL(kstrimdup);
> +
> +/**
>   * kmemdup - duplicate region of memory
>   *
>   * @src: memory region to duplicate

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
