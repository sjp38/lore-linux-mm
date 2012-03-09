Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B715F6B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 15:33:40 -0500 (EST)
Received: by vcbfk14 with SMTP id fk14so2274128vcb.14
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 12:33:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120309202722.GA10323@x61.redhat.com>
References: <CAOJsxLFQjV1c7nQZMA2voybN0AdhGrKFN5svQHC2C=oP3vOD4g@mail.gmail.com>
	<20120309202722.GA10323@x61.redhat.com>
Date: Fri, 9 Mar 2012 22:33:39 +0200
Message-ID: <CAOJsxLHX5bU03t32ONDeuT2pq88FLAQpw7DtAxTGL8Qe0_wFzg@mail.gmail.com>
Subject: Re: [PATCH v3] mm: SLAB Out-of-memory diagnostics
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, David Rientjes <rientjes@google.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Fri, Mar 9, 2012 at 10:27 PM, Rafael Aquini <aquini@redhat.com> wrote:
> Following the example at mm/slub.c, add out-of-memory diagnostics to the
> SLAB allocator to help on debugging certain OOM conditions.
>
> An example print out looks like this:
>
> =A0<snip page allocator out-of-memory message>
> =A0SLAB: Unable to allocate memory on node 0 (gfp=3D0x11200)
> =A0 =A0cache: bio-0, object size: 192, order: 0
> =A0 =A0node 0: slabs: 3/3, objs: 60/60, free: 0
>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>

David?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
