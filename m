Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id B56936B0035
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 09:16:22 -0500 (EST)
Received: by mail-bk0-f51.google.com with SMTP id 6so1449758bkj.38
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 06:16:21 -0800 (PST)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id qw8si8204108bkb.211.2013.11.24.06.16.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Nov 2013 06:16:21 -0800 (PST)
Received: by mail-la0-f45.google.com with SMTP id eh20so2191138lab.4
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 06:16:21 -0800 (PST)
Date: Sun, 24 Nov 2013 15:15:49 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] mm/zswap: change params from hidden to ro
Message-ID: <20131124141545.GA2106@hp530>
References: <1384965522-5788-1-git-send-email-ddstreet@ieee.org>
 <20131120173347.GA2369@hp530>
 <CALZtONA81=R4abFMpMMtDZKQe0s-8+JxvEfZO3NEZ910VwRDmw@mail.gmail.com>
 <20131122073851.GB1853@hp530>
 <CALZtONA-CdTJ=cg3cnacEz0uDtQVinkqkyPQuNSCWT18OD+Y5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <CALZtONA-CdTJ=cg3cnacEz0uDtQVinkqkyPQuNSCWT18OD+Y5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, Seth Jennings <sjennings@variantweb.net>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Fri, Nov 22, 2013 at 12:18:01PM -0500, Dan Streetman wrote:
> On Fri, Nov 22, 2013 at 2:38 AM, Vladimir Murzin <murzin.v@gmail.com> wrote:
> > On Wed, Nov 20, 2013 at 12:52:47PM -0500, Dan Streetman wrote: > On Wed, Nov
> > 20, 2013 at 12:33 PM, Vladimir Murzin <murzin.v@gmail.com> wrote: > > Hi Dan!
> >> >
> >> > On Wed, Nov 20, 2013 at 11:38:42AM -0500, Dan Streetman wrote:
> >> >> The "compressor" and "enabled" params are currently hidden,
> >> >> this changes them to read-only, so userspace can tell if
> >> >> zswap is enabled or not and see what compressor is in use.
> >> >
> >> > Could you elaborate more why this pice of information is necessary for
> >> > userspace?
> >>
> >> For anyone interested in zswap, it's handy to be able to tell if it's
> >> enabled or not ;-)  Technically people can check to see if the zswap
> >> debug files are in /sys/kernel/debug/zswap, but I think the actual
> >> "enabled" param is more obvious.  And the compressor param is really
> >> the only way anyone from userspace can see what compressor's being
> >> used; that's helpful to know for anyone that might want to be using a
> >> non-default compressor.
> >
> > So, it is needed for user not userspace? I tend to think that users are smart
> > enough to check cmdline for that.
> 
> Let's try a different way.  Can you explain what the problem is with
> making these params user-readable?

This patch is absolutely neutral for me - nothing bad and nothing good. I've just
been curious what argument for this patch you have except "let it be".

Thanks
Vadimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
