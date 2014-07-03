Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 340756B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 11:41:39 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so414208pad.38
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 08:41:38 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id fi4si33193179pbb.193.2014.07.03.08.41.35
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 08:41:37 -0700 (PDT)
Message-ID: <53B579AD.1010201@sr71.net>
Date: Thu, 03 Jul 2014 08:41:33 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] RFC: userfault
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\"Dr. David Alan Gilbert\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Paolo Bonzini <pbonzini@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Mel Gorman <mgorman@suse.de>

On 07/02/2014 09:50 AM, Andrea Arcangeli wrote:
> The MADV_USERFAULT feature should be generic enough that it can
> provide the userfaults to the Android volatile range feature too, on
> access of reclaimed volatile pages.

Maybe.

I certainly can't keep track of all the versions of the variations of
the volatile ranges patches.  But, I don't think it's a given that this
can be reused.  First of all, volatile ranges is trying to replace
ashmem and is going to require _some_ form of sharing.  This mechanism,
being tightly coupled to anonymous memory at the moment, is not a close
fit for that.

It's also important to call out that this is a VMA-based mechanism.  I
certainly can't predict what we'll merge for volatile ranges, but not
all of them are VMA-based.  We'd also need a mechanism on top of this to
differentiate plain not-present pages from not-present-because-purged pages.

That said, I _think_ this might fit well in to what the Mozilla guys
wanted out of volatile ranges.  I'm not confident about it, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
