Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id BDB3E6B0038
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:43:32 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so962936pbc.25
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:43:32 -0700 (PDT)
Date: Wed, 2 Oct 2013 14:43:29 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Problems with RAID 4/5/6 and kmem_cache
In-Reply-To: <CAOJsxLGaNe_cap7fx8ZRZPWqkQhUbpA07Qhtgsg_+c5JdgV=qQ@mail.gmail.com>
Message-ID: <00000141799facf7-d62f6643-9499-4a8b-8a13-b9c751316d97-000000@email.amazonses.com>
References: <1379646960-12553-1-git-send-email-jbrassow@redhat.com> <0000014142863060-919062ff-7284-445d-b3ec-f38cc8d5a6c8-000000@email.amazonses.com> <CAOJsxLGaNe_cap7fx8ZRZPWqkQhUbpA07Qhtgsg_+c5JdgV=qQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Jonathan Brassow <jbrassow@redhat.com>, linux-raid@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, 28 Sep 2013, Pekka Enberg wrote:

> Do we need to come up with something less #ifdeffy for v3.13?

It would be nice to have something that also checks the runtime debug
configuration. But so far debugging is only switchable at runtime for SLUB
and not for SLAB. We could get that when we unify the object debugging in
both allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
