Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 56EE16B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 14:33:55 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id cc10so7471111wib.17
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 11:33:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t1si12265567wjx.67.2014.02.12.11.33.52
        for <linux-mm@kvack.org>;
        Wed, 12 Feb 2014 11:33:53 -0800 (PST)
Date: Wed, 12 Feb 2014 14:33:34 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140212143334.76850251@redhat.com>
In-Reply-To: <20140212023711.GT11821@two.firstfloor.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <20140211211732.GS11821@two.firstfloor.org>
 <20140211163108.3136d55a@redhat.com>
 <20140212023711.GT11821@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com

On Wed, 12 Feb 2014 03:37:11 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> > The real syntax is hugepagesnid=nid,nr-pages,size. Which looks straightforward
> > to me. I honestly can't think of anything better than that, but I'm open for
> > suggestions.
> 
> hugepages_node=nid:nr-pages:size,... ? 

Looks good, I'll consider using it for v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
