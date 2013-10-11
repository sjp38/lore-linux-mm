Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0A54A6B0037
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 04:57:14 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so3853309pbb.24
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 01:57:14 -0700 (PDT)
Date: Fri, 11 Oct 2013 16:57:01 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [uml-devel] BUG: soft lockup for a user mode linux image
Message-ID: <20131011085701.GA27382@localhost>
References: <CAMuHMdUo8dSd4s3089ZDEc485wL1sFxBKLeaExJuqNiQY+S-Lw@mail.gmail.com>
 <5251CF94.5040101@gmx.de>
 <CAMuHMdWs6Y7y12STJ+YXKJjxRF0k5yU9C9+0fiPPmq-GgeW-6Q@mail.gmail.com>
 <525591AD.4060401@gmx.de>
 <5255A3E6.6020100@nod.at>
 <20131009214733.GB25608@quack.suse.cz>
 <5255D9A6.3010208@nod.at>
 <5256DA9A.5060904@gmx.de>
 <20131011011649.GA11191@localhost>
 <5257B9EB.7080503@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5257B9EB.7080503@gmx.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Richard Weinberger <richard@nod.at>, Jan Kara <jack@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>

On Fri, Oct 11, 2013 at 10:42:19AM +0200, Toralf FA?rster wrote:
> yeah, now the picture becomes more clear
> ...
> net.core.warnings = 0                                                                         [ ok ]
> ick: pause : -717
>                  ick : min_pause : -177
>                                    ick : max_pause : -717
>                                                      ick: pages_dirtied : 14
>                                                                             ick: task_ratelimit: 0

Great and thanks! So it's the max pause calculation went wrong.
Would help you try the below patch?
