Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0BC6B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:11:04 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n18-v6so3095763iog.10
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:11:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6-v6sor2297027itd.0.2018.06.27.19.11.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 19:11:03 -0700 (PDT)
MIME-Version: 1.0
References: <60052659-7b37-cb69-bf9f-1683caa46219@redhat.com>
In-Reply-To: <60052659-7b37-cb69-bf9f-1683caa46219@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 27 Jun 2018 19:10:51 -0700
Message-ID: <CA+55aFzeA7N3evSF2jKHu8JoTQuKDLCMKx7RiPhmym97-8HY7A@mail.gmail.com>
Subject: Re: [PATCH] mm: reject MAP_SHARED_VALIDATE without new flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Sandeen <sandeen@redhat.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-ext4@vger.kernel.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, zhibli@redhat.com

On Wed, Jun 27, 2018 at 6:45 PM Eric Sandeen <sandeen@redhat.com> wrote:
>
> Thus the invalid flag combination of (MAP_SHARED|MAP_PRIVATE) now
> passes without error, which is a regression.

It's not a regression, it's just new behavior.

"regression" doesn't mean "things changed". It means "something broke".

What broke?

Because if it's some manual page breakage, just fix the manual. That's
what "new behavior" is all about.

There is nothing that says that "MAP_SHARED_VALIDATE" can't work with
just the legacy flags.

Because I'd be worried about your patch breaking some actual new user
of MAP_SHARED_VALIDATE.

Because it's actual *users* of behavior we care about, not some
test-suite or manual pages.

              Linus
