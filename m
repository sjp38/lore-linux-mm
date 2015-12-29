Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id E54EB6B0278
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:01:27 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id mw1so39023852igb.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 09:01:27 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id l10si44467528igx.44.2015.12.29.09.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 29 Dec 2015 09:01:27 -0800 (PST)
Date: Tue, 29 Dec 2015 11:01:25 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <567C522E.50207@oracle.com>
Message-ID: <alpine.DEB.2.20.1512291059580.28632@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org> <567860EB.4000103@oracle.com> <56786A22.9030103@oracle.com> <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org> <567C522E.50207@oracle.com>
Content-Type: text/plain; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.20.1512291059582.28632@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 24 Dec 2015, Sasha Levin wrote:

> >> > [ 3462.527795]   pwq 4: cpus=2 node=2 flags=0x0 nice=0 active=1/256
> >> > [ 3462.554836]     pending: vmstat_update
> > Does that mean that vmstat_update locks up or something that schedules it?
>
> I think it means that vmstat_update didn't finish running (working).

There is nothing in there that blocks.

> > Also what workload triggers the BUG()?
>
> Fuzzing with trinity inside a KVM guest. I've attached my config.

Ok will have a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
