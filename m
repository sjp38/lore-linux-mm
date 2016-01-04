Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 815016B0003
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 13:05:30 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id to4so248941008igc.0
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 10:05:30 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id y79si32076356ioi.7.2016.01.04.10.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 10:05:29 -0800 (PST)
Date: Mon, 4 Jan 2016 12:05:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <567C522E.50207@oracle.com>
Message-ID: <alpine.DEB.2.20.1601041158460.26970@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org> <567860EB.4000103@oracle.com> <56786A22.9030103@oracle.com> <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org> <567C522E.50207@oracle.com>
Content-Type: text/plain; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.20.1601041158462.26970@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, 24 Dec 2015, Sasha Levin wrote:

> > Also what workload triggers the BUG()?
>
> Fuzzing with trinity inside a KVM guest. I've attached my config.

Ok build and bootup works fine after fix from Tetsuo to config. Does not
like my initrd it seems. Is there a root with the tools available somehow?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
