Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 64BA66B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 19:46:58 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4MNksaT021772
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 22 May 2011 16:46:55 -0700
Received: by eyd9 with SMTP id 9so2475177eyd.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 16:46:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1105221518180.17400@sister.anvils>
References: <alpine.LSU.2.00.1105221518180.17400@sister.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 22 May 2011 16:46:34 -0700
Message-ID: <BANLkTimpi2vhx3NzR71G640HXXn-keCoqQ@mail.gmail.com>
Subject: Re: Adding an ugliness in __read_cache_page()?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, May 22, 2011 at 3:25 PM, Hugh Dickins <hughd@google.com> wrote:
>
> But drivers/gpu/drm i915 and ttm are using read_cache_page_gfp() or
> read_mapping_page() on tmpfs: on objects created by shmem_file_setup().
>
> Nothing else uses read_cache_page_gfp(). =A0I cannot find anything else
> using read_mapping_page() on tmpfs, but wonder if something might be
> out there. =A0Stacked filesystems appear not to go that way nowadays.
>
> Would it be better to make i915 and ttm call shmem_read_cache_page()
> directly? =A0Perhaps removing the then unused read_cache_page_gfp(), or
> perhaps not: may still be needed for i915 and ttm on tiny !SHMEM ramfs.

I would certainly prefer the "make i915 and ttm call
shmem_read_cache_page directly" approach over putting some nasty hack
in __read_cache_page.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
