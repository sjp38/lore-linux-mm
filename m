Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5AAD6B0069
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:28:28 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id f27so16232927ote.16
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:28:28 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j129sor7576313oif.123.2017.11.27.11.28.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 11:28:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171127162207.GA8265@bombadil.infradead.org>
References: <23066.59196.909026.689706@gargle.gargle.HOWL> <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <20171127162207.GA8265@bombadil.infradead.org>
From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Mon, 27 Nov 2017 20:28:27 +0100
Message-ID: <CAM43=SOAU2-qTB2cHeZs5xGzPFKwoqtTafqtw+BqCP9cbQDUOQ@mail.gmail.com>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Mon, Nov 27, 2017 at 5:22 PM, Matthew Wilcox <willy@infradead.org> wrote:
>> Could you be more explicit about _why_ we need to remove this tunable?
>> I am not saying I disagree, the removal simplifies the code but I do not
>> really see any justification here.
>
> I imagine he started seeing random syscalls failing with ENOMEM and
> eventually tracked it down to this stupid limit we used to need.

Exactly, except the origin (mmap() failing) was hidden behind layers upon layers
of user-space memory management code (not ours), which just said "failed to
allocate N bytes" (with N about 0.001% of the free RAM).  And it
wasn't reproducible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
