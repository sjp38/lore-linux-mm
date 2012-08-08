Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id EBFED6B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 13:46:46 -0400 (EDT)
Date: Wed, 8 Aug 2012 12:45:34 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [14/20] Shrink __kmem_cache_create() parameter lists
In-Reply-To: <50226659.8080608@parallels.com>
Message-ID: <alpine.DEB.2.02.1208081234590.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192156.005879886@linux.com> <50226659.8080608@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.02.1208081234592.7756@greybox.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, 8 Aug 2012, Glauber Costa wrote:

> On 08/03/2012 11:21 PM, Christoph Lameter wrote:
> > Do the initial settings of the fields in common code. This will allow
> > us to push more processing into common code later and improve readability.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Doesn't compile.

Resequencing. Sigh. Fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
