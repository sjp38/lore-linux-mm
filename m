Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 4B87F6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 02:28:37 -0400 (EDT)
Received: by yenm7 with SMTP id m7so3819128yen.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 23:28:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120523203433.340661918@linux.com>
References: <20120523203433.340661918@linux.com>
Date: Wed, 30 May 2012 09:28:35 +0300
Message-ID: <CAOJsxLHHrURa=4=4Ptop4yQ4SNzLHsKc+vmLwYKO4oMUtHQtyg@mail.gmail.com>
Subject: Re: Common 00/22] Sl[auo]b: Common functionality V3
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Wed, May 23, 2012 at 11:34 PM, Christoph Lameter <cl@linux.com> wrote:
> This is a series of patches that extracts common functionality from
> slab allocators into a common code base. The intend is to standardize
> as much as possible of the allocator behavior while keeping the
> distinctive features of each allocator which are mostly due to their
> storage format and serialization approaches.

Matt, any comments on the SLOB changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
