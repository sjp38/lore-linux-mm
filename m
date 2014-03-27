Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 050D16B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:36:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3660847pad.28
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:36:20 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ph6si1770583pab.308.2014.03.27.08.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 08:36:20 -0700 (PDT)
Message-ID: <53344452.7090107@oracle.com>
Date: Thu, 27 Mar 2014 11:31:30 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG: Bad page state in process ksmd
References: <5332EE97.4050604@oracle.com> <alpine.LSU.2.11.1403270806340.4269@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1403270806340.4269@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 03/27/2014 11:21 AM, Hugh Dickins wrote:
> I've thought about this some, and slept on it, but don't yet see
> how it comes about.  I'll have to come back to it later.
>
> Was it a one-off, or do you find it fairly easy to reproduce?
>
> If the latter, it would be interesting to know if it comes from
> recent changes or not.  mm/mlock.c does appear to have been under
> continuous revision for several releases (but barely changed in next).

I can't say it's easy to reproduce but it did happen 5-6 times at this point.

As far as I can tell there were no big changes in trinity for the last week
or so while we were in lsf/mm, and this issue being reproducible makes me
believe it has something to do with recent changes to mm code.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
