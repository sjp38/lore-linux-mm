Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B8CAC6B0036
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 21:19:28 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so1219096pab.16
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 18:19:28 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id oq9si11373246pac.209.2014.01.22.18.19.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 18:19:27 -0800 (PST)
Message-ID: <52E07B63.1070400@oracle.com>
Date: Wed, 22 Jan 2014 21:16:03 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG: Bad rss-counter state
References: <52E06B6F.90808@oracle.com> <alpine.DEB.2.02.1401221735450.26172@chino.kir.corp.google.com> <20140123015241.GA947@redhat.com>
In-Reply-To: <20140123015241.GA947@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, David Rientjes <rientjes@google.com>, khlebnikov@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/22/2014 08:52 PM, Dave Jones wrote:
> Sasha, is this the current git tree version of Trinity ?
> (I'm wondering if yesterdays munmap changes might be tickling this bug).

Ah yes, my tree has the munmap patch from yesterday, which would explain why we
started seeing this issue just now.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
