Received: by wf-out-1314.google.com with SMTP id 28so370266wfc.11
        for <linux-mm@kvack.org>; Wed, 26 Nov 2008 00:05:06 -0800 (PST)
Message-ID: <84144f020811260005s2e54e05fy45e14c6ab3b7c3f@mail.gmail.com>
Date: Wed, 26 Nov 2008 10:05:06 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Fix comment on #endif
In-Reply-To: <1227622099.15127.8.camel@plop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1227622099.15127.8.camel@plop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pascal Terjan <pterjan@mandriva.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 25, 2008 at 4:08 PM, Pascal Terjan <pterjan@mandriva.com> wrote:
> This #endif in slab.h is described as closing the inner block while it's for
> the big CONFIG_NUMA one. That makes reading the code a bit harder.
>
> This trivial patch fixes the comment.
>
> Signed-off-by: Pascal Terjan <pterjan@mandriva.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
