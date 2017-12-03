Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 110FD6B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 05:04:50 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n6so10415252pfg.19
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 02:04:50 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k1si7622398pgp.422.2017.12.03.02.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Dec 2017 02:04:48 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: Memory corruption in powerpc guests with virtio_balloon (was Re: [PATCH v3] virtio_balloon: fix deadlock on OOM)
In-Reply-To: <20171201164129-mutt-send-email-mst@kernel.org>
References: <1510154064-9709-1-git-send-email-mst@redhat.com> <87o9nid3zn.fsf@concordia.ellerman.id.au> <20171201164129-mutt-send-email-mst@kernel.org>
Date: Sun, 03 Dec 2017 21:04:40 +1100
Message-ID: <87lgikw2iv.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

"Michael S. Tsirkin" <mst@redhat.com> writes:
> On Fri, Dec 01, 2017 at 11:31:08PM +1100, Michael Ellerman wrote:
>> "Michael S. Tsirkin" <mst@redhat.com> writes:
>> 
>> > fill_balloon doing memory allocations under balloon_lock
>> > can cause a deadlock when leak_balloon is called from
>> > virtballoon_oom_notify and tries to take same lock.
...
>> 
>> 
>> Somehow this commit seems to be killing powerpc guests.
...
>
> Thanks for the report!
> A fix was just posted:
> virtio_balloon: fix increment of vb->num_pfns in fill_balloon()
>
> Would appreciate testing.

Yep that fixes it. Thanks.

Tested-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
