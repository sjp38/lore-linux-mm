Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 54CFD6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 10:17:47 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hl2so2657222igb.0
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:17:47 -0800 (PST)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id 38si1310870iop.81.2015.01.23.07.17.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 07:17:46 -0800 (PST)
Date: Fri, 23 Jan 2015 09:17:44 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
In-Reply-To: <20150123141817.GA22926@phnom.home.cmpxchg.org>
Message-ID: <alpine.DEB.2.11.1501230908560.15325@gentwo.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, mhocko@suse.cz

On Fri, 23 Jan 2015, Johannes Weiner wrote:

> Is the assumption of this patch wrong?  Does the specified node have
> to be online for the fallback to work?

Nodes that are offline have no control structures allocated and thus
allocations will likely segfault when the address of the controls
structure for the node is accessed.

If we wanted to prevent that then every allocation would have to add a
check to see if the nodes are online which would impact performance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
