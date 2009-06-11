Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 654E16B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 12:06:50 -0400 (EDT)
Message-ID: <4A312B9F.4010208@redhat.com>
Date: Thu, 11 Jun 2009 12:06:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] HWPOISON: remove early kill option for now
References: <20090611142239.192891591@intel.com> <20090611144430.682162784@intel.com>
In-Reply-To: <20090611144430.682162784@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> It needs more thoughts, and is not a must have for .31.
> 
> CC: Nick Piggin <npiggin@suse.de>
> CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Fair enough.  It's not an absolute must-have and still needs
a little bit more work.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
