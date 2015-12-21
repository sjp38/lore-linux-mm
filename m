Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id A47C96B0005
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 16:14:20 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id to18so44511049igc.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 13:14:20 -0800 (PST)
Received: from resqmta-po-07v.sys.comcast.net (resqmta-po-07v.sys.comcast.net. [2001:558:fe16:19:96:114:154:166])
        by mx.google.com with ESMTPS id i2si18024894iof.127.2015.12.21.13.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Dec 2015 13:14:20 -0800 (PST)
Date: Mon, 21 Dec 2015 15:14:18 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <56786A22.9030103@oracle.com>
Message-ID: <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org> <567860EB.4000103@oracle.com> <56786A22.9030103@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 21 Dec 2015, Sasha Levin wrote:

> I've also noticed a new warning from the workqueue code which my scripts
> didn't pick up before:
>
> [ 3462.380681] BUG: workqueue lockup - pool cpus=2 node=2 flags=0x4 nice=0 stuck for 54s!
> [ 3462.522041] workqueue vmstat: flags=0xc
> [ 3462.527795]   pwq 4: cpus=2 node=2 flags=0x0 nice=0 active=1/256
> [ 3462.554836]     pending: vmstat_update

Does that mean that vmstat_update locks up or something that schedules it?

Also what workload triggers the BUG()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
