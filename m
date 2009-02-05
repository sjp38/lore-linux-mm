Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 803976B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 17:25:31 -0500 (EST)
Date: Thu, 5 Feb 2009 14:25:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
 retain extra mm_count.
Message-Id: <20090205142527.59bddf45.akpm@linux-foundation.org>
In-Reply-To: <20090205172303.GB8559@sgi.com>
References: <20090205172303.GB8559@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, andrea@qumranet.com, npiggin@suse.de, cl@linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009 11:23:03 -0600
Robin Holt <holt@sgi.com> wrote:

> CC: Stable kernel maintainers <stable@vger.kernel.org>

stable@kernel.org.

The vger address might work, I don't know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
