Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 046296B000E
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 04:28:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f3-v6so642781wre.11
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 01:28:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 132-v6sor258125wmd.20.2018.07.03.01.28.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 01:28:15 -0700 (PDT)
Date: Tue, 3 Jul 2018 10:28:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86: make Memory Management options more visible
Message-ID: <20180703082812.GA971@gmail.com>
References: <af12c83d-2533-ae00-b53c-1fc1a9d8e9ce@infradead.org>
 <20180702140612.GA7333@infradead.org>
 <afcb4a42-891a-d732-f072-79c0a1fc49f0@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afcb4a42-891a-d732-f072-79c0a1fc49f0@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, X86 ML <x86@kernel.org>


* Randy Dunlap <rdunlap@infradead.org> wrote:

> On 07/02/2018 07:06 AM, Christoph Hellwig wrote:
> > On Sun, Jul 01, 2018 at 07:48:38PM -0700, Randy Dunlap wrote:
> >> From: Randy Dunlap <rdunlap@infradead.org>
> >>
> >> Currently for x86, the "Memory Management" kconfig options are
> >> displayed under "Processor type and features."  This tends to
> >> make them hidden or difficult to find.
> >>
> >> This patch makes Memory Managment options a first-class menu by moving
> >> it away from "Processor type and features" and into the main menu.
> >>
> >> Also clarify "endmenu" lines with '#' comments of their respective
> >> menu names, just to help people who are reading or editing the
> >> Kconfig file.
> >>
> >> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> > 
> > Hmm, can you take off from this for now and/or rebase it on top of
> > this series:
> > 
> > 	http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/kconfig-cleanups
> > 
> 
> Sure, no problem.

Also:

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo
