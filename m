Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 1DBE56B0037
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 15:17:51 -0400 (EDT)
Date: Tue, 2 Apr 2013 19:17:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/3] slub: correct to calculate num of acquired objects
 in get_partial_node()
In-Reply-To: <CAOJsxLH7Vhi1ady+uu5Vn-o5bW4rd6MiJZ1Okjqo2nX-JjgXAQ@mail.gmail.com>
Message-ID: <0000013dcc2f1037-3e5332ff-5a67-4db8-bcbe-c1c163ef2914-000000@email.amazonses.com>
References: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com> <20130319051045.GB8858@lge.com> <CAOJsxLH7Vhi1ady+uu5Vn-o5bW4rd6MiJZ1Okjqo2nX-JjgXAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2 Apr 2013, Pekka Enberg wrote:

> On Tue, Mar 19, 2013 at 7:10 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > Could you pick up 1/3, 3/3?
> > These are already acked by Christoph.
> > 2/3 is same effect as Glauber's "slub: correctly bootstrap boot caches",
> > so should skip it.
>
> Applied, thanks!

Could you also put in

1. The fixes for the hotpath using preempt/enable/disable that were
discussed with the RT folks a couple of months ago.

2. The fixes from the slab next branch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
