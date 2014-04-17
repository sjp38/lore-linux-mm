Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id C3C2C6B0092
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 11:13:31 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id d1so3083039wiv.1
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 08:13:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fa13si9119110wjc.105.2014.04.17.08.13.29
        for <linux-mm@kvack.org>;
        Thu, 17 Apr 2014 08:13:30 -0700 (PDT)
Date: Thu, 17 Apr 2014 11:13:05 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v3 0/5] hugetlb: add support gigantic page allocation at
 runtime
Message-ID: <20140417111305.485fa956@redhat.com>
In-Reply-To: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

On Thu, 10 Apr 2014 13:58:40 -0400
Luiz Capitulino <lcapitulino@redhat.com> wrote:

> [Full introduction right after the changelog]
> 
> Changelog
> ---------
> 
> v3
> 
> - Dropped unnecessary WARN_ON() call [Kirill]
> - Always check if the pfn range lies within a zone [Yasuaki]
> - Renamed some function arguments for consistency

Andrew, this series got four ACKs but it seems that you haven't picked
it yet. Is there anything missing to be addressed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
