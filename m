Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 145956B00BF
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 07:20:32 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id z12so2593382lbi.36
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 04:20:32 -0800 (PST)
Received: from mail.emea.novell.com (mail.emea.novell.com. [130.57.118.101])
        by mx.google.com with ESMTPS id tn9si431718lbb.72.2014.11.04.04.20.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 04:20:31 -0800 (PST)
Message-Id: <5458D29A0200007800044C76@mail.emea.novell.com>
Date: Tue, 04 Nov 2014 12:20:26 +0000
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] mm: Improve comment before
 pagecache_isize_extended()
References: <1415101390-18301-1-git-send-email-jack@suse.cz>
In-Reply-To: <1415101390-18301-1-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org

>>> On 04.11.14 at 12:43, <"jack@suse.cz".non-mime.internet> wrote:
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -743,10 +743,13 @@ EXPORT_SYMBOL(truncate_setsize);
>   * changed.
>   *
>   * The function must be called after i_size is updated so that page =
fault
> - * coming after we unlock the page will already see the new i_size.
> - * The function must be called while we still hold i_mutex - this not =
only
> - * makes sure i_size is stable but also that userspace cannot observe =
new
> - * i_size value before we are prepared to store mmap writes at new =
inode size.
> + * coming after we unlock the page will already see the new i_size.  =
The caller
> + * must make sure (generally by holding i_mutex but e.g. XFS uses its =
private
> + * lock) i_size cannot change from the new value while we are called. =
It must
> + * also make sure userspace cannot observe new i_size value before we =
are
> + * prepared to store mmap writes upto new inode size (otherwise =
userspace could
> + * think it stored data via mmap within i_size but they would get =
zeroed due to
> + * writeback & reclaim because they have no backing blocks).
>   */
>  void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t =
to)
>  {

May I suggest that the comment preceding truncate_setsize() also be
updated/removed?

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
