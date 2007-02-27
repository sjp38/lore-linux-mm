Received: by nf-out-0910.google.com with SMTP id b2so71191nfe
        for <linux-mm@kvack.org>; Mon, 26 Feb 2007 22:26:28 -0800 (PST)
Message-ID: <21d7e9970702262226v6fc70e06jd759c66c383630e1@mail.gmail.com>
Date: Tue, 27 Feb 2007 17:26:28 +1100
From: "Dave Airlie" <airlied@gmail.com>
Subject: Re: [patch 0/6] fault vs truncate/invalidate race fix
In-Reply-To: <20070226213204.14f8b584.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070221023656.6306.246.sendpatchset@linux.site>
	 <21d7e9970702262036h3575229ex3bf3cd4474a57068@mail.gmail.com>
	 <20070226213204.14f8b584.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: npiggin@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On 2/27/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Tue, 27 Feb 2007 15:36:03 +1100 "Dave Airlie" <airlied@gmail.com> wrote:
> > >
> > > I've also got rid of the horrible populate API, and integrated nonlinear pages
> > > properly with the page fault path.
> > >
> > > Downside is that this adds one more vector through which the buffered write
> > > deadlock can occur. However this is just a very tiny one (pte being unmapped
> > > for reclaim), compared to all the other ways that deadlock can occur (unmap,
> > > reclaim, truncate, invalidate). I doubt it will be noticable. At any rate, it
> > > is better than data corruption.
> > >
> > > I hope these can get merged (at least into -mm) soon.
> >
> > Have these been put into mm?
>
> Not yet - I need to get back on the correct continent, review the code,
> stuff like that.  It still hurts that this work makes the write() deadlock
> harder to hit, and we haven't worked out how to fix that.
>
> > can I expect them in the next -mm so I
> > can start merging up the drm memory manager code to my -mm tree..
>
> What is the linkage between these patches and DRM?
>

the new fault hander made the memory manager code a lot cleaner and
very less hacky in a lot of cases. so I'd rather merge the clean code
than have to fight with the current code...

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
