Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 11F166B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 22:16:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <c5c17e83-a21c-4360-a201-3bb865062961@default>
Date: Mon, 24 May 2010 19:15:59 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Cleancache [PATCH 2/7] (was Transcendent Memory): core files
References: <20100422132809.GA27302@ca-server1.us.oracle.com
 20100514231815.GY30031@ZenIV.linux.org.uk
 1b84523f-a7df-4d6a-870f-b684bd012230@default>
In-Reply-To: <1b84523f-a7df-4d6a-870f-b684bd012230@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: chris.mason@oracle.com, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > The third one is pgoff_t; again, use sane types, _if_ you actually
> want
> > the argument #3 at all - it can be derived from struct page you are
> > passing there as well.
>=20
> I thought it best to declare the _ops so that the struct page
> is opaque to the "backend" (driver).  The kernel-side ("frontend")
> defines the handle and ensures coherency, so the backend shouldn't
> be allowed to derive or muck with the three-tuple passed by the
> kernel. In the existing (Xen tmem) driver, the only operation
> performed on the struct page parameter is page_to_pfn().  OTOH,
> I could go one step further and pass a pfn_t instead of a
> struct page, since it is really only the physical page frame that
> the backend needs to know about and (synchronously) read/write from/to.
>=20
> Thoughts?

Silly me.  pfn_t is a Xen/KVM type not otherwise used in the
kernel AFAICT.  Please ignore...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
