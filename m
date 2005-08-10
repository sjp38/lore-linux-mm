From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
Date: Wed, 10 Aug 2005 23:34:42 +1000
References: <20050808145430.15394c3c.akpm@osdl.org> <200508090724.30962.phillips@arcor.de> <31567.1123679613@warthog.cambridge.redhat.com>
In-Reply-To: <31567.1123679613@warthog.cambridge.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200508102334.43662.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Wednesday 10 August 2005 23:13, David Howells wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> > > ...kill PG_checked please :)  Or at least keep it from spreading.
> >
> > It already spread - ext3 is using it and I think reiser4.  I thought I
> > had a patch to rename it to PG_misc1 or somesuch, but no.  It's mandate
> > becomes "filesystem-specific page flag".
>
> You're carrying a patch to stick a flag called PG_fs_misc, but that has the
> same value as PG_checked. An extra page flag beyond PG_uptodate, PG_lock
> and PG_writeback is required to make readpage through the cache
> non-synchronous.

David,

Interesting, have you got a pointer to a full explanation?  Is this about aio?

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
