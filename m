Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D33AE6B0035
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:44:48 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so3534947pdj.11
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:44:48 -0800 (PST)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id r7si7920212pbk.357.2014.01.30.13.44.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:44:47 -0800 (PST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so3660105pbb.29
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:44:47 -0800 (PST)
Date: Thu, 30 Jan 2014 13:44:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 1/2] mm: add kstrimdup function
In-Reply-To: <20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401301343430.15271@chino.kir.corp.google.com>
References: <1391116318-17253-1-git-send-email-sebastian.capella@linaro.org> <1391116318-17253-2-git-send-email-sebastian.capella@linaro.org> <20140130132251.4f662aeddc09d8410dee4490@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sebastian Capella <sebastian.capella@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Joe Perches <joe@perches.com>, Mikulas Patocka <mpatocka@redhat.com>, Michel Lespinasse <walken@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 30 Jan 2014, Andrew Morton wrote:

> > @@ -63,6 +64,35 @@ char *kstrndup(const char *s, size_t max, gfp_t gfp)
> >  EXPORT_SYMBOL(kstrndup);
> >  
> >  /**
> > + * kstrimdup - Trim and copy a %NUL terminated string.
> > + * @s: the string to trim and duplicate
> > + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
> > + *
> > + * Returns an address, which the caller must kfree, containing
> > + * a duplicate of the passed string with leading and/or trailing
> > + * whitespace (as defined by isspace) removed.
> > + */
> > +char *kstrimdup(const char *s, gfp_t gfp)
> > +{
> > +	char *buf;
> > +	char *begin = skip_spaces(s);
> > +	size_t len = strlen(begin);
> > +
> > +	while (len > 1 && isspace(begin[len - 1]))
> > +		len--;
> 
> That's off-by-one isn't it?  kstrimdup("   ") should return "", not " ".
> 

Yeah, this is an incorrect copy-and-paste of Joe Perches' suggested code 
from http://marc.info/?l=linux-kernel&m=139104508317989.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
