Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 732678E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 15:05:36 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r131so22525121oia.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 12:05:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24sor19133405oik.152.2019.01.02.12.05.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 12:05:35 -0800 (PST)
MIME-Version: 1.0
References: <20181203170934.16512-1-vpillai@digitalocean.com>
 <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils>
 <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
 <alpine.LSU.2.11.1901012010440.13241@eggly.anvils> <CANaguZC_d2EBmNuXtcJRcEcw8uXK234tYSXx6Uc2o9JH_vfP4A@mail.gmail.com>
 <alpine.LSU.2.11.1901021039490.13761@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1901021039490.13761@eggly.anvils>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Wed, 2 Jan 2019 15:05:25 -0500
Message-ID: <CANaguZDcJa9NxZU4Z3Q7DqvQK5zsDXZKNbhbO8fcppnYrTxMHw@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

On Wed, Jan 2, 2019 at 2:43 PM Hugh Dickins <hughd@google.com> wrote:

>
> Wrong.  Without heavier locking that would add unwelcome overhead to
> common paths, we shall "always" need the retry logic.  It does not
> come into play very often, but here are two examples of why it's
> needed (if I thought longer, I might find more).  And in practice,
> yes, I sometimes saw 1 retry needed.
>
Understood. Sorry, I missed these corner cases.

> I don't use frontswap myself, and haven't paid any attention to the
> frontswap partial swapoff case (though notice now that shmem_unuse()
> lacks the plumbing needed for it - that needs fixing); but doubt it
> would be a good idea to refactor it out as a separate case.
>
I shall rework the shmem side to take care of the frontswap and retain
the retry logic in a simplified manner.

Thanks again for all the comments and insights..

~Vineeth
