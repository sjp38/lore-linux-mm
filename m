Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B3A4F6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 01:45:26 -0400 (EDT)
Received: by yenr5 with SMTP id r5so13289191yen.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 22:45:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120706202509.294809131@linux.com>
References: <20120706202509.294809131@linux.com>
Date: Tue, 10 Jul 2012 08:45:24 +0300
Message-ID: <CAOJsxLEU685SkxaxMLDxYJUpjyLyXAV03X7ZLJh--jhk+n8gMw@mail.gmail.com>
Subject: Re: Common [0/4] Sl[auo]b: Common code rework V6 (limited)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On Fri, Jul 6, 2012 at 11:25 PM, Christoph Lameter <cl@linux.com> wrote:
> This is a series of patches that extracts common functionality from
> slab allocators into a common code base. The intend is to standardize
> as much as possible of the allocator behavior while keeping the
> distinctive features of each allocator which are mostly due to their
> storage format and serialization approaches.

Works fine here. David, Glauber, does the series look OK to move forward with?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
