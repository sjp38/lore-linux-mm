Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 49F046B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 11:51:24 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so134951066qkh.2
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 08:51:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l91si8646959qkh.85.2015.04.16.08.51.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Apr 2015 08:51:23 -0700 (PDT)
Message-ID: <552FDA78.7040505@redhat.com>
Date: Thu, 16 Apr 2015 11:51:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86, mm: Trace when an IPI is about to be sent
References: <1429179766-26711-1-git-send-email-mgorman@suse.de> <1429179766-26711-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1429179766-26711-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 04/16/2015 06:22 AM, Mel Gorman wrote:
> It is easy to trace when an IPI is received to flush a TLB but harder to
> detect what event sent it. This patch makes it easy to identify the source
> of IPIs being transmitted for TLB flushes on x86.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
