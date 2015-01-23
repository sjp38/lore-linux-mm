Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0466B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 16:09:23 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id v10so7682304qac.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 13:09:23 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id s10si3482468qcz.21.2015.01.23.13.09.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 13:09:22 -0800 (PST)
Date: Fri, 23 Jan 2015 15:09:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
In-Reply-To: <54C2B01D.4070303@roeck-us.net>
Message-ID: <alpine.DEB.2.11.1501231508020.7871@gentwo.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org> <alpine.DEB.2.11.1501231419420.11767@gentwo.org> <54C2B01D.4070303@roeck-us.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Fri, 23 Jan 2015, Guenter Roeck wrote:

> Wouldn't that have unintended consequences ? So far
> rb tree nodes are allocated even if a node not online;
> the above would change that. Are you saying it is
> unnecessary to initialize rb tree nodes if the node
> is not online ?

It is not advisable to allocate since an offline node means that the
structure cannot be allocated on the node where it would be most
beneficial. Typically subsystems allocate the per node data structures
when the node is brought online.

> Not that I have any idea what is correct, it just seems odd
> that the existing code would do all this allocation if it is not
> necessary.

Not sure how the code there works just guessing from other subsystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
