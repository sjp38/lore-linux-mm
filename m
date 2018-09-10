Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D26A18E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 02:47:46 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e6-v6so39729018itc.7
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 23:47:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4-v6sor9198753iog.44.2018.09.09.23.47.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Sep 2018 23:47:45 -0700 (PDT)
MIME-Version: 1.0
References: <CAOMGZ=G52R-30rZvhGxEbkTw7rLLwBGadVYeo--iizcD3upL3A@mail.gmail.com>
In-Reply-To: <CAOMGZ=G52R-30rZvhGxEbkTw7rLLwBGadVYeo--iizcD3upL3A@mail.gmail.com>
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Mon, 10 Sep 2018 08:47:32 +0200
Message-ID: <CAOMGZ=GometWFFaFYmv7y=ByG=VjjarE=-Yic7sSK15uRtw0EA@mail.gmail.com>
Subject: Re: v4.18.0+ WARNING: at mm/vmscan.c:1756 isolate_lru_page + bad page state
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, 30 Aug 2018 at 15:31, Vegard Nossum <vegard.nossum@gmail.com> wrote:
>
> Hi,
>
> Got this on a recent kernel (pretty sure it was
> 2ad0d52699700a91660a406a4046017a2d7f246a but annoyingly the oops
> itself doesn't tell me the exact version):
>
> ------------[ cut here ]------------
> trying to isolate tail page
> WARNING: CPU: 2 PID: 19156 at mm/vmscan.c:1756 isolate_lru_page+0x235/0x250

[...]

> I don't have the capacity to debug it atm and it may even have been
> fixed in mainline (though searching didn't yield any other reports
> AFAICT).
>
> I have .config and vmlinux (with DEBUG_INFO=y) if needed.
>
> It's not reproducible for the time being.

Just a quick follow-up: I have a reproducer and Kirill Shutemov has
identified the problem and provided a tentative patch.


Vegard
