Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B96E6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:41:11 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id c8so1579650lfe.16
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:41:11 -0800 (PST)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.184])
        by mx.google.com with ESMTPS id s64si7580402lfg.76.2018.01.12.07.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 07:41:08 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 04/36] usercopy: Prepare for usercopy whitelisting
Date: Fri, 12 Jan 2018 15:10:42 +0000
Message-ID: <b8c3f85827ca493e9f4517f646ac97da@AcuMS.aculab.com>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-5-git-send-email-keescook@chromium.org>
 <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
In-Reply-To: <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Christopher Lameter' <cl@linux.com>, Kees Cook <keescook@chromium.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David
 Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David
 Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de
 Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik
 van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

From: Christopher Lameter
> Sent: 10 January 2018 18:28
> On Tue, 9 Jan 2018, Kees Cook wrote:
>=20
> > +struct kmem_cache *kmem_cache_create_usercopy(const char *name,
> > +			size_t size, size_t align, slab_flags_t flags,
> > +			size_t useroffset, size_t usersize,
> > +			void (*ctor)(void *));
>=20
> Hmmm... At some point we should switch kmem_cache_create to pass a struct
> containing all the parameters. Otherwise the API will blow up with
> additional functions.

Or add an extra function to 'configure' the kmem_cache with the
extra parameters.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
