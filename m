Received: by ag-out-0708.google.com with SMTP id 22so6414022agd.8
        for <linux-mm@kvack.org>; Thu, 17 Jul 2008 11:07:40 -0700 (PDT)
Date: Thu, 17 Jul 2008 21:06:16 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [RFC PATCH 3/4] kmemtrace: SLUB hooks.
Message-ID: <20080717180615.GA5360@localhost>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro> <017a63e6be64502c36ede4733f0cc4e5ede75db2.1216255035.git.eduard.munteanu@linux360.ro> <84144f020807170046j2fae2f41k7c80dba4e388677b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020807170046j2fae2f41k7c80dba4e388677b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 17, 2008 at 10:46:51AM +0300, Pekka Enberg wrote:
> On Thu, Jul 17, 2008 at 3:46 AM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > This adds hooks for the SLUB allocator, to allow tracing with kmemtrace.
> >
> > Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> > ---
> >  include/linux/slub_def.h |    9 +++++++-
> >  mm/slub.c                |   47 ++++++++++++++++++++++++++++++++++++++++-----
> >  2 files changed, 49 insertions(+), 7 deletions(-)
> 
> What are these casts doing here? I think you can just drop them, no?

Yes, I should cut all these casts off. Will resubmit soon.


	Eduard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
