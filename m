Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD226B025C
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:21:36 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id to4so64384658igc.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:21:36 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id b19si2998880igr.100.2015.12.22.09.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 09:21:35 -0800 (PST)
Date: Tue, 22 Dec 2015 11:21:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org>
Message-ID: <alpine.DEB.2.20.1512221120420.14270@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <alpine.DEB.2.20.1512210656120.7119@east.gentwo.org> <567860EB.4000103@oracle.com> <56786A22.9030103@oracle.com> <alpine.DEB.2.20.1512211513360.27237@east.gentwo.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Ran this here but no errors. Need config etc to reproduce.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
