Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 59AF86B0071
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 14:16:44 -0400 (EDT)
Date: Tue, 23 Oct 2012 18:16:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slab: move kmem_cache_free to common code
In-Reply-To: <508561E0.5000406@parallels.com>
Message-ID: <0000013a8ed7437d-636573ea-beb9-44fd-8519-3725d2675a50-000000@email.amazonses.com>
References: <1350914737-4097-1-git-send-email-glommer@parallels.com> <1350914737-4097-3-git-send-email-glommer@parallels.com> <0000013a88eff593-50da3bb8-3294-41db-9c32-4e890ef6940a-000000@email.amazonses.com> <508561E0.5000406@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Mon, 22 Oct 2012, Glauber Costa wrote:

> > This results in an additional indirection if tracing is off. Wonder if
> > there is a performance impact?
> >
> if tracing is on, you mean?

Sorry I meant *even* if tracing is off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
