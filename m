Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 311196B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 12:32:57 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so5241911pdj.40
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:32:56 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id m12si30640238icb.53.2014.07.19.09.32.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 09:32:55 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so5592754iec.33
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:32:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407160307460.1775@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-6-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1407160307460.1775@eggly.anvils>
Date: Sat, 19 Jul 2014 18:32:55 +0200
Message-ID: <CANq1E4TDfQ3dXOgaaSD5dwVMk4seYzE0TW0_4smP2Aj0p0TrPQ@mail.gmail.com>
Subject: Re: [PATCH v3 5/7] selftests: add memfd/sealing page-pinning tests
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Wed, Jul 16, 2014 at 12:08 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 13 Jun 2014, David Herrmann wrote:
>
>> Setting SEAL_WRITE is not possible if there're pending GUP users. This
>> commit adds selftests for memfd+sealing that use FUSE to create pending
>> page-references. FUSE is very helpful here in that it allows us to delay
>> direct-IO operations for an arbitrary amount of time. This way, we can
>> force the kernel to pin pages and then run our normal selftests.
>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>
> I had a number of problems in getting this working (on openSUSE 13.1):
> rpm told me I had fuse installed, yet I had to download and install
> the tarball to get header files needed; then "make fuse_mnt" told me
> to add -D_FILE_OFFSET_BITS=64 to the compile flags; after which I
> got "undefined reference to `fuse_main_real'"; but then I tried
> "make run_fuse" as root, and it seemed to sort these issues out
> for itself, aside from "./run_fuse_test.sh: Permission denied" -
> which was within my bounds of comprehension unlike the rest!
>
> No complaint, thanks for providing the test (though I didn't check
> the source to convince myself that "DONE" has done what's claimed):
> some rainy day someone can get the Makefile working more smoothly,
> no need to delay the patchset for this.

_FILE_OFFSET_BITS=64 makes sense. I added it. The "undefined ref"
thing doesn't make sense to me and I cannot reproduce it. I will see
what I can do.

The "Permission denied" obviously just requires access to /dev/fuse,
as you figured out yourself.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
