Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2CA6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 17:26:02 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so868285pdb.17
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 14:26:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id vy8si1867927pab.194.2014.10.01.14.26.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 14:26:01 -0700 (PDT)
Date: Wed, 1 Oct 2014 14:25:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, compaction: using uninitialized_var insteads
 setting 'flags' to 0 directly.
Message-Id: <20141001142559.20b8c87f792bc046cdabd309@linux-foundation.org>
In-Reply-To: <542C6FB2.8000503@suse.cz>
References: <1411961425-8045-1-git-send-email-Li.Xiubo@freescale.com>
	<542A5B5B.7060207@suse.cz>
	<alpine.DEB.2.02.1410011314180.21593@chino.kir.corp.google.com>
	<542C6FB2.8000503@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Xiubo Li <Li.Xiubo@freescale.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, minchan@kernel.org, Arnd Bergmann <arnd@arndb.de>

On Wed, 01 Oct 2014 23:18:42 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 10/01/2014 10:16 PM, David Rientjes wrote:
> >> On 09/29/2014 05:30 AM, Xiubo Li wrote:
> >> > Setting 'flags' to zero will be certainly a misleading way to avoid
> >> > warning of 'flags' may be used uninitialized. uninitialized_var is
> >> > a correct way because the warning is a false possitive.
> >> 
> >> Agree.
> >> 
> >> > Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
> >> 
> >> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >> 
> > 
> > I thought we just discussed this when 
> > mm-compaction-fix-warning-of-flags-may-be-used-uninitialized.patch was 
> > merged and, although I liked it, it was stated that we shouldn't add any 
> > new users of uninitialized_var().
> 
> Yeah but that discussion wasn't unfortunately CC'd on mailing lists. And my
> interpretation of the outcome is that maybe we should try :)
> 

https://lkml.org/lkml/2012/10/27/71

I disagree, can't be bothered getting into a fight over it.  I do tend
to accidentally let new uses sneak into the tree, but this one is a bit
obvious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
