Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id D30C86B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 14:27:58 -0500 (EST)
Date: Mon, 25 Feb 2013 19:27:57 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: slab: Verify the nodeid passed to
 ____cache_alloc_node
In-Reply-To: <512BA33C.6060506@redhat.com>
Message-ID: <0000013d12d36816-5dd04154-a1ab-4a0e-977d-9690c597f12e-000000@email.amazonses.com>
References: <591256534.8212978.1361812690861.JavaMail.root@redhat.com> <512BA33C.6060506@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Aaron Tomlin <atomlin@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, glommer@parallels.com

On Mon, 25 Feb 2013, Rik van Riel wrote:

> On 02/25/2013 12:18 PM, Aaron Tomlin wrote:
>
> > mm: slab: Verify the nodeid passed to ____cache_alloc_node
> >
> > If the nodeid is > num_online_nodes() this can cause an
> > Oops and a panic(). The purpose of this patch is to assert
> > if this condition is true to aid debugging efforts rather
> > than some random NULL pointer dereference or page fault.
> >
> > Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
>
> Reviewed-by: Rik van Riel <riel@redhat.com>

It may be helpful to cc the slab maintainers...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
