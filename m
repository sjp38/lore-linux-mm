Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE0E6B0009
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:28:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r1so2357899pgp.2
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:28:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j73si1612849pgc.566.2018.02.14.12.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:28:39 -0800 (PST)
Date: Wed, 14 Feb 2018 12:28:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 3/8] Convert virtio_console to kvzalloc_struct
Message-ID: <20180214202835.GE20627@bombadil.infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
 <20180214201154.10186-4-willy@infradead.org>
 <1518639587.3678.25.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518639587.3678.25.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, Feb 14, 2018 at 12:19:47PM -0800, Joe Perches wrote:
> On Wed, 2018-02-14 at 12:11 -0800, Matthew Wilcox wrote:
> >  	 */
> > -	buf = kmalloc(sizeof(*buf) + sizeof(struct scatterlist) * pages,
> > -		      GFP_KERNEL);
> > +	buf = kvzalloc_struct(buf, sg, pages, GFP_KERNEL);
> >  	if (!buf)
> 
> kvfree?

Yes, that would also need to be done.  The point of these last six
patches was to show the API in use, not for applying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
