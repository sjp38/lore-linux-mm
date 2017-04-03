Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF916B0038
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 11:52:14 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b10so144914355pgn.8
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 08:52:14 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c80si14661337pfc.329.2017.04.03.08.52.13
        for <linux-mm@kvack.org>;
        Mon, 03 Apr 2017 08:52:13 -0700 (PDT)
Date: Mon, 3 Apr 2017 16:51:52 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Bad page state splats on arm64, v4.11-rc{3,4}
Message-ID: <20170403155152.GG18905@leverpostej>
References: <20170331175845.GE6488@leverpostej>
 <20170403105629.GB18905@leverpostej>
 <20170403113751.GD5706@arm.com>
 <20170403154815.GE25550@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170403154815.GE25550@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, punit.agrawal@arm.com, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, Apr 03, 2017 at 04:48:15PM +0100, Catalin Marinas wrote:
> On Mon, Apr 03, 2017 at 12:37:51PM +0100, Will Deacon wrote:
> > On Mon, Apr 03, 2017 at 11:56:29AM +0100, Mark Rutland wrote:
> > > On Fri, Mar 31, 2017 at 06:58:45PM +0100, Mark Rutland wrote:

> > > > I'm seeing intermittent bad page state splats on arm64 with 4.11-rc3 and
> > > > v4.11-rc4.

> > > I wasn't able to trigger the issue over the weekend on a kernel with
> > > HUGETLBFS disabled. There are known issues with our handling of
> > > contiguous entries, and this might be an artefact of that.
> > 
> > After chatting with Punit, it looks like this might be because the GUP
> > code doesn't handle huge ptes (which we create using the contiguous hint),
> > so follow_page_pte ends up with one of those and goes wrong. In particular,
> > the migration code will certainly do the wrong thing.
> > 
> > I'll probably revert the contiguous support (again) if testing indicates
> > that it makes this issue disappear.
> 
> It might be worth checking with Punit's patches as well:
> 
> https://marc.info/?l=linux-arm-kernel&m=149089199018167&w=2

I'd given those patches a spin prior to testing v4.11-rc4 with HUGETLBFS
disabled.

I saw the issue even with those patches applied.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
