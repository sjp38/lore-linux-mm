Date: Thu, 14 Dec 2006 08:40:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slab: fix kmem_ptr_validate prototype
In-Reply-To: <1166099200.32332.233.camel@twins>
Message-ID: <Pine.LNX.4.64.0612140839440.28557@schroedinger.engr.sgi.com>
References: <1166099200.32332.233.camel@twins>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-648802997-1166114426=:28557"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

---1700579579-648802997-1166114426=:28557
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 14 Dec 2006, Peter Zijlstra wrote:

> Some fallout of: 2e892f43ccb602e8ffad73396a1000f2040c9e0b
>=20
>   CC mm/slab.o /usr/src/linux-2.6-git/mm/slab.c:3557: error: conflicting=
=20
> types for =FF=FFkmem_ptr_validate=FF=FF=20
> /usr/src/linux-2.6-git/include/linux/slab.h:58: error: previous=20
> declaration of =FF=FFkmem_ptr_validate=FF=FF was here

Why do we need the fastcall there? What is its role?

---1700579579-648802997-1166114426=:28557--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
