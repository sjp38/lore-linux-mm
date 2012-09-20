Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 9FC3B6B0068
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 14:55:00 -0400 (EDT)
Message-ID: <505B6680.2000609@redhat.com>
Date: Thu, 20 Sep 2012 14:54:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/6] Revert "mm: have order > 0 compaction start off where
 it left"
References: <1348149875-29678-1-git-send-email-mgorman@suse.de> <1348149875-29678-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1348149875-29678-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20/2012 10:04 AM, Mel Gorman wrote:
> This reverts commit 7db8889a (mm: have order > 0 compaction start off
> where it left) and commit de74f1cc (mm: have order > 0 compaction start
> near a pageblock with free pages). These patches were a good idea and
> tests confirmed that they massively reduced the amount of scanning but
> the implementation is complex and tricky to understand. A later patch
> will cache what pageblocks should be skipped and reimplements the
> concept of compact_cached_free_pfn on top for both migration and
> free scanners.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Sure, it makes your next patches easier...

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
