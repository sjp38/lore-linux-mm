Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C50C86B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 03:26:26 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id hm14so1750718wib.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2013 00:26:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1014891011.990074.1366727496599.JavaMail.root@redhat.com>
References: <1081382531.982691.1366726661820.JavaMail.root@redhat.com>
	<1014891011.990074.1366727496599.JavaMail.root@redhat.com>
Date: Wed, 24 Apr 2013 10:26:24 +0300
Message-ID: <CAOJsxLHRskQ81ouGVTqqQpOK3ZQDf6fpw5UYDFi7MY1ij=kmfg@mail.gmail.com>
Subject: Re: [Patch v2] mm: slab: Verify the nodeid passed to ____cache_alloc_node
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Rik <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>

On Tue, Apr 23, 2013 at 5:31 PM, Aaron Tomlin <atomlin@redhat.com> wrote:
> This patch is in response to BZ#42967 [1].
> Using VM_BUG_ON so it's used only when CONFIG_DEBUG_VM is set,
> given that ____cache_alloc_node() is a hot code path.

The patch is pretty badly mangled and does not apply with 'git am'.
Please resend with updated ACKs.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
