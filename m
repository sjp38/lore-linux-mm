Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 642CC82F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:54:57 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so21512900igb.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:54:57 -0700 (PDT)
Received: from mail-io0-x230.google.com (mail-io0-x230.google.com. [2607:f8b0:4001:c06::230])
        by mx.google.com with ESMTPS id h65si17841644ioi.167.2015.10.16.12.54.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 12:54:56 -0700 (PDT)
Received: by ioii196 with SMTP id i196so134691485ioi.3
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:54:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1445025093-32639-1-git-send-email-cmetcalf@ezchip.com>
References: <CA+55aFyzsMYcRX3V5CEWB4Zb-9BuRGCjib3DMXuX5y9nBWiZ1w@mail.gmail.com>
	<1445025093-32639-1-git-send-email-cmetcalf@ezchip.com>
Date: Fri, 16 Oct 2015 12:54:56 -0700
Message-ID: <CA+55aFx_2HUHXQDrOYpB3qpqg=LqMw0zjTj9S7ctgg9c6Hy_Ew@mail.gmail.com>
Subject: Re: [PATCH] vmstat_update: ensure work remains on the same core
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@ezchip.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>

On Fri, Oct 16, 2015 at 12:51 PM, Chris Metcalf <cmetcalf@ezchip.com> wrote:
> By using schedule_delayed_work(), we are preferring the local
> core for the work, but not requiring it.

Heh. See commit 176bed1de5bf.

I added curly braces, because I hate the "half-bracing" that the code
had (ie a "else" statement with curly braces on one side but not the
other), but otherwise identical patches, I think.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
