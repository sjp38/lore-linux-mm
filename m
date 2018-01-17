Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E87586B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:31:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id r28so2500424pgu.1
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 11:31:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id a9si4295867pgf.136.2018.01.17.11.31.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 11:31:16 -0800 (PST)
Date: Wed, 17 Jan 2018 11:31:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: kmem_cache_attr (was Re: [PATCH 04/36] usercopy: Prepare for
 usercopy whitelisting)
Message-ID: <20180117193114.GB25862@bombadil.infradead.org>
References: <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
 <20180114230719.GB32027@bombadil.infradead.org>
 <alpine.DEB.2.20.1801160913260.3908@nuc-kabylake>
 <20180116160525.GF30073@bombadil.infradead.org>
 <alpine.DEB.2.20.1801161049320.5162@nuc-kabylake>
 <20180116174315.GA10461@bombadil.infradead.org>
 <alpine.DEB.2.20.1801161205590.1771@nuc-kabylake>
 <alpine.DEB.2.20.1801161215500.2945@nuc-kabylake>
 <20180116210313.GA7791@bombadil.infradead.org>
 <alpine.DEB.2.20.1801171141430.23209@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1801171141430.23209@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, kernel-hardening@lists.openwall.com

On Wed, Jan 17, 2018 at 11:42:34AM -0600, Christopher Lameter wrote:
> On Tue, 16 Jan 2018, Matthew Wilcox wrote:
> 
> > struct kmem_cache_attr {
> > 	char name[16];
> 
> That doesnt work. memcg needs long slab names. Sigh.

Oof.  That's ugly.  Particularly ugly in that it could actually share the
attr with the root cache, except for the name.

We could put a char * in the kmem_cache which (if not NULL) overrides
the attr->name?  Probably want a helper to replace the endearingly short
's->name'.  Something like:

#define slab_name(s)	s->name ?: s->attr->name

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
