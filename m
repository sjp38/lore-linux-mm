Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 074A56B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 20:03:16 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p4N03Fe0026312
	for <linux-mm@kvack.org>; Sun, 22 May 2011 17:03:15 -0700
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by wpaz1.hot.corp.google.com with ESMTP id p4N039Zv020732
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 22 May 2011 17:03:14 -0700
Received: by pxi16 with SMTP id 16so3408189pxi.32
        for <linux-mm@kvack.org>; Sun, 22 May 2011 17:03:09 -0700 (PDT)
Date: Sun, 22 May 2011 17:03:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Adding an ugliness in __read_cache_page()?
In-Reply-To: <BANLkTimpi2vhx3NzR71G640HXXn-keCoqQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1105221702150.1427@sister.anvils>
References: <alpine.LSU.2.00.1105221518180.17400@sister.anvils> <BANLkTimpi2vhx3NzR71G640HXXn-keCoqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-143352963-1306108997=:1427"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-143352963-1306108997=:1427
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 22 May 2011, Linus Torvalds wrote:
> On Sun, May 22, 2011 at 3:25 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > Would it be better to make i915 and ttm call shmem_read_cache_page()
> > directly? =A0Perhaps removing the then unused read_cache_page_gfp(), or
> > perhaps not: may still be needed for i915 and ttm on tiny !SHMEM ramfs.
>=20
> I would certainly prefer the "make i915 and ttm call
> shmem_read_cache_page directly" approach over putting some nasty hack
> in __read_cache_page.

Thank you: I'll go that way.

Hugh
--8323584-143352963-1306108997=:1427--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
