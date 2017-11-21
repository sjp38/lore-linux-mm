Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D12CA6B025F
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 20:04:32 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d14so7046268wrg.15
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 17:04:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p10si9422107wrf.530.2017.11.20.17.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 17:04:31 -0800 (PST)
Date: Mon, 20 Nov 2017 17:04:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-Id: <20171120170429.315726fb004905314ced614e@linux-foundation.org>
In-Reply-To: <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
	<20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
	<20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
	<20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
	<20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
	<20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
	<06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
	<20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz>
	<20171116100633.moui6zu33ctzpjsf@techsingularity.net>
	<CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, Steve Sistare <steven.sistare@oracle.com>

On Fri, 17 Nov 2017 13:19:56 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> On Thu, Nov 16, 2017 at 5:06 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> > 4. Put a check into the page allocator slowpath that triggers serialised
> >    init if the system is booting and an allocation is about to fail. It
> >    would be such a cold path that it would never be noticable although it
> >    would leave dead code in the kernel image once boot had completed
> 
> Hi Mel,
> 
> The forth approach is the best as it is seamless for admins and
> engineers, it will also work on any system configuration with any
> parameters without any special involvement.

Apart from what-mel-said, I'd be concerned that this failsafe would
almost never get tested.  We should find some way to ensure that this
code gets exercised in some people's kernels on a permanent basis and
I'm not sure how to do that.

One option might be to ask Fengguang to add the occasional
test_pavels_stuff=1 to the kernel boot commandline.  That's better
than nothing but 0-day only runs on a small number of machine types.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
