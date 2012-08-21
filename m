Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A334E6B0069
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 11:37:25 -0400 (EDT)
Date: Tue, 21 Aug 2012 15:37:24 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/5] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
In-Reply-To: <20120821072611.GC1657@suse.de>
Message-ID: <0000013949d4c42b-231ae8aa-8ef8-47a4-b658-6c3fb5961347-000000@email.amazonses.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-6-git-send-email-mgorman@suse.de> <000001394596bd69-2c16d7fb-71b5-4009-95cc-7068103b2bfd-000000@email.amazonses.com> <20120821072611.GC1657@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, 21 Aug 2012, Mel Gorman wrote:

> mempolicy: fix a memory corruption by refcount imbalance in alloc_pages_vma()

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
