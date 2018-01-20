Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2060F6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 20:58:41 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id r196so3560121itc.4
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 17:58:41 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id c76si9287896iod.220.2018.01.19.17.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 17:58:40 -0800 (PST)
Date: Fri, 19 Jan 2018 19:58:38 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
In-Reply-To: <20180117193114.GB25862@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1801191957160.14056@nuc-kabylake>
References: <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <20180114230719.GB32027@bombadil.infradead.org> <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake> <20180116160525.GF30073@bombadil.infradead.org> <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake>
 <20180116174315.GA10461@bombadil.infradead.org> <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake> <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake> <20180116210313.GA7791@bombadil.infradead.org> <alpine.DEB.2.20.1801171141430.23209@nuc-kabylake>
 <20180117193114.GB25862@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, kernel-hardening@lists.openwall.com



On Wed, 17 Jan 2018, Matthew Wilcox wrote:

> We could put a char * in the kmem_cache which (if not NULL) overrides
> the attr->name?  Probably want a helper to replace the endearingly short
> 's->name'.  Something like:
>
> #define slab_name(s)	s->name ?: s->attr->name


Well I was planning on replacing references to const objects in
kmem_cache_attr throughout the allocators with s->a->xx where a is the
pointer to the attributes in struct kmem_cache. That is also a security
feature if the kmem_cache_attr structures can be placed in readonly
segmenets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
