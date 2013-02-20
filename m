Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 519C16B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 09:24:03 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 13so9968306iea.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 06:24:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1359699013-7160-1-git-send-email-hannes@cmpxchg.org>
References: <1359699013-7160-1-git-send-email-hannes@cmpxchg.org>
Date: Wed, 20 Feb 2013 22:24:02 +0800
Message-ID: <CANN689Hwp-fm-SUzAXAqLKGkGHxjw2X+pkQRr01=Fjq=BaSoDQ@mail.gmail.com>
Subject: Re: [patch] mm: mlock: document scary-looking stack expansion mlock chain
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 1, 2013 at 2:10 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> The fact that mlock calls get_user_pages, and get_user_pages might
> call mlock when expanding a stack looks like a potential recursion.
>
> However, mlock makes sure the requested range is already contained
> within a vma, so no stack expansion will actually happen from mlock.
>
> Should this ever change: the stack expansion mlocks only the newly
> expanded range and so will not result in recursive expansion.
>
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michel Lespinasse <walken@google.com>

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
