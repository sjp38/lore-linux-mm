Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8674C6B0006
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 18:35:56 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id h85-v6so11057675ybg.23
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 15:35:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g78-v6sor10563ywe.560.2018.06.25.15.35.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Jun 2018 15:35:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2e4d9686-835c-f4be-2647-2344899e3cd4@redhat.com>
References: <1529939300-27461-1-git-send-email-crecklin@redhat.com>
 <d110c9af-cb68-5a3c-bc70-0c7650edb0d4@redhat.com> <cfd52ae6-6fea-1a5a-b2dd-4dfdd65acd15@redhat.com>
 <2e4d9686-835c-f4be-2647-2344899e3cd4@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 25 Jun 2018 15:35:54 -0700
Message-ID: <CAGXu5jJGqxKjcWGyAnbkmFebtPor0PEQ+2qpoMCGtjjdYRTHDw@mail.gmail.com>
Subject: Re: [PATCH] add param that allows bootline control of hardened usercopy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris von Recklinghausen <crecklin@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Jun 25, 2018 at 3:29 PM, Christoph von Recklinghausen
<crecklin@redhat.com> wrote:
> I have a small set of customers that want CONFIG_HARDENED_USERCOPY
> enabled, and a large number of customers who would be impacted by its
> default behavior (before my change).  The desire was to have the smaller
> number of users need to change their boot lines to get the behavior they
> wanted. Adding CONFIG_HUC_DEFAULT_OFF was an attempt to preserve the
> default behavior of existing users of CONFIG_HARDENED_USERCOPY (default
> enabled) and allowing that to coexist with the desires of the greater
> number of my customers (default disabled).
>
> If folks think that it's better to have it enabled by default and the
> command line option to turn it off I can do that (it is simpler). Does
> anyone else have opinions one way or the other?

I would prefer to isolate the actual problem case, and fix it if
possible. (i.e. try to make the copy fixed-length, etc) Barring that,
yes, a kernel command line to disable the protection would be okay.

Note that the test needs to be inside __check_object_size() otherwise
the inline optimization with __builtin_constant_p() gets broken and
makes everyone slower. :)

-Kees

-- 
Kees Cook
Pixel Security
