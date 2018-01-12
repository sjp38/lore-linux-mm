Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4322F6B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:57:27 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m4so4960566iob.16
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:57:27 -0800 (PST)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [96.114.154.162])
        by mx.google.com with ESMTPS id h62si1361868iof.3.2018.01.12.07.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 07:57:26 -0800 (PST)
Date: Fri, 12 Jan 2018 09:56:21 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: RE: [PATCH 04/36] usercopy: Prepare for usercopy whitelisting
In-Reply-To: <b8c3f85827ca493e9f4517f646ac97da@AcuMS.aculab.com>
Message-ID: <alpine.DEB.2.20.1801120955540.12791@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org> <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake> <b8c3f85827ca493e9f4517f646ac97da@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: Kees Cook <keescook@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri, 12 Jan 2018, David Laight wrote:

> > Hmmm... At some point we should switch kmem_cache_create to pass a struct
> > containing all the parameters. Otherwise the API will blow up with
> > additional functions.
>
> Or add an extra function to 'configure' the kmem_cache with the
> extra parameters.

We probably need even more configurability if we add callbacks for object
reclaim / moving.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
