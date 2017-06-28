Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07DDC6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 12:55:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m188so63665342pgm.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:55:24 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id i68si1884348pgc.593.2017.06.28.09.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 09:55:23 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id z6so9741258pfk.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 09:55:23 -0700 (PDT)
Date: Wed, 28 Jun 2017 09:55:20 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [kernel-hardening] [PATCH 17/23] dcache: define usercopy region
 in dentry_cache slab cache
Message-ID: <20170628165520.GA129364@gmail.com>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-18-git-send-email-keescook@chromium.org>
 <20170620040834.GB610@zzz.localdomain>
 <CAGXu5jJyyO8CmukmmZdfmt34pubr8EzRJ4H2AMjc15UpLzrGcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJyyO8CmukmmZdfmt34pubr8EzRJ4H2AMjc15UpLzrGcQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 28, 2017 at 09:44:13AM -0700, Kees Cook wrote:
> On Mon, Jun 19, 2017 at 9:08 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > On Mon, Jun 19, 2017 at 04:36:31PM -0700, Kees Cook wrote:
> >> From: David Windsor <dave@nullcore.net>
> >>
> >> When a dentry name is short enough, it can be stored directly in
> >> the dentry itself.  These dentry short names, stored in struct
> >> dentry.d_iname and therefore contained in the dentry_cache slab cache,
> >> need to be coped to/from userspace.
> >>
> >> In support of usercopy hardening, this patch defines a region in
> >> the dentry_cache slab cache in which userspace copy operations
> >> are allowed.
> >>
> >> This region is known as the slab cache's usercopy region.  Slab
> >> caches can now check that each copy operation involving cache-managed
> >> memory falls entirely within the slab's usercopy region.
> >>
> >> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
> >> whitelisting code in the last public patch of grsecurity/PaX based on my
> >> understanding of the code. Changes or omissions from the original code are
> >> mine and don't reflect the original grsecurity/PaX code.
> >>
> >
> > For all these patches please mention *where* the data is being copied to/from
> > userspace.
> 
> Can you explain what you mean here? The field being copied is already
> mentioned in the commit log; do you mean where in the kernel source
> does the copy happen?
> 

Yes, for the ones where it isn't obvious, mentioning a syscall or ioctl might be
sufficient.  Others may need more explanation.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
