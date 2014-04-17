Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0D36B004D
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 14:52:46 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so648583pdi.5
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 11:52:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id td10si15063786pac.427.2014.04.17.11.52.45
        for <linux-mm@kvack.org>;
        Thu, 17 Apr 2014 11:52:45 -0700 (PDT)
Date: Thu, 17 Apr 2014 11:52:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/5] hugetlb: add support gigantic page allocation at
 runtime
Message-Id: <20140417115242.1081267213b26d10a41d2266@linux-foundation.org>
In-Reply-To: <20140417111305.485fa956@redhat.com>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
	<20140417111305.485fa956@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

On Thu, 17 Apr 2014 11:13:05 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:

> On Thu, 10 Apr 2014 13:58:40 -0400
> Luiz Capitulino <lcapitulino@redhat.com> wrote:
> 
> > [Full introduction right after the changelog]
> > 
> > Changelog
> > ---------
> > 
> > v3
> > 
> > - Dropped unnecessary WARN_ON() call [Kirill]
> > - Always check if the pfn range lies within a zone [Yasuaki]
> > - Renamed some function arguments for consistency
> 
> Andrew, this series got four ACKs but it seems that you haven't picked
> it yet. Is there anything missing to be addressed?

I don't look at new features until after -rc1.  Then it takes a week or
more to work through the backlog.  We'll get there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
