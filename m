Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3D966B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 16:32:55 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b19so1208740wmb.8
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 13:32:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z19si1023014wmc.58.2017.06.15.13.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 13:32:54 -0700 (PDT)
Date: Thu, 15 Jun 2017 13:32:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/3] mm: huge pages: Misc fixes for issues found
 during fuzzing
Message-Id: <20170615133252.3191c75d7b33a8bb7cad2004@linux-foundation.org>
In-Reply-To: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
References: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, vbabka@suse.cz

On Tue, 13 Jun 2017 11:28:39 +0100 Will Deacon <will.deacon@arm.com> wrote:

> This is v2 of the patches previously posted here:
> 
>    http://www.spinics.net/lists/linux-mm/msg128577.html
> 
> Changes since v1 include:
> 
>   * Use smp_mb() instead of smp_mb__before_atomic() before atomic_set()
>   * Added acks and fixes tag
> 
> Feedback welcome,
> 
> Will
> 
> --->8
> 
> Mark Rutland (1):
>   mm: numa: avoid waiting on freed migrated pages
> 
> Will Deacon (2):
>   mm/page_ref: Ensure page_ref_unfreeze is ordered against prior
>     accesses
>   mm: migrate: Stabilise page count when migrating transparent hugepages

I marked [1/3] for -stable backporting and held the other two for
4.13-rc1.  Maybe that wasn't appropriate...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
