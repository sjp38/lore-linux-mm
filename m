Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFFD6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 22:38:39 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so3310689pbc.4
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 19:38:39 -0700 (PDT)
Received: from mail-vb0-f41.google.com (mail-vb0-f41.google.com [209.85.212.41])
	by muin.pair.com (Postfix) with ESMTPSA id 3F9488FC31
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 22:38:36 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id g17so2086522vbg.0
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 19:38:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1380724087-13927-14-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
	<1380724087-13927-14-git-send-email-jack@suse.cz>
Date: Thu, 3 Oct 2013 21:38:35 -0500
Message-ID: <CAOZdJXXsgUOHL9tLpY3v5Hq9+NLOxpSJxE8=6U397cKHP52n1g@mail.gmail.com>
Subject: Re: [PATCH 13/26] fsl_hypervisor: Convert ioctl_memcpy() to use get_user_pages_fast()
From: Timur Tabi <timur@tabi.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Timur Tabi <timur@freescale.com>

On Wed, Oct 2, 2013 at 9:27 AM, Jan Kara <jack@suse.cz> wrote:
> CC: Timur Tabi <timur@freescale.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---

This seems okay, but I don't have access to hardware at the moment to test it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
