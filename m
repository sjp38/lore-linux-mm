Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D41D76B005A
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:35:19 -0400 (EDT)
Message-ID: <4A313284.2060409@redhat.com>
Date: Thu, 11 Jun 2009 12:36:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] HWPOISON: use the safer invalidate page for possible
 metadata pages
References: <20090611142239.192891591@intel.com> <20090611144430.947740750@intel.com>
In-Reply-To: <20090611144430.947740750@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> As recommended by Nick Piggin.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
