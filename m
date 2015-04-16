Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id AB1BA6B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 12:55:44 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so98174083pdb.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 09:55:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qy7si12864192pab.240.2015.04.16.09.55.43
        for <linux-mm@kvack.org>;
        Thu, 16 Apr 2015 09:55:43 -0700 (PDT)
Message-ID: <552FE98F.2080705@intel.com>
Date: Thu, 16 Apr 2015 09:55:43 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86, mm: Trace when an IPI is about to be sent
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1429179766-26711-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2015 03:22 AM, Mel Gorman wrote:
> It is easy to trace when an IPI is received to flush a TLB but harder to
> detect what event sent it. This patch makes it easy to identify the source
> of IPIs being transmitted for TLB flushes on x86.

Looks fine to me.  I think I even thought about adding this but didn't
see an immediate need for it.  I guess this does let you see how many
IPIs are sent vs. received.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
