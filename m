Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FB666B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 18:11:51 -0400 (EDT)
Message-ID: <4C6DAC15.7040004@redhat.com>
Date: Thu, 19 Aug 2010 18:11:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] writeback: kernel visibility
References: <1282251447-16937-1-git-send-email-mrubin@google.com>
In-Reply-To: <1282251447-16937-1-git-send-email-mrubin@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, akpm@linux-foundation.org, david@fromorbit.com, npiggin@suse.de, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On 08/19/2010 04:57 PM, Michael Rubin wrote:
> Patch #1 sets up some helper functions for accounting.
>
> Patch #2 adds writeback visibility in /proc/sys/vm.
>
> To help developers and applications gain visibility into writeback
> behaviour adding two read-only sysctl files into /proc/sys/vm.
> These files allow user apps to understand writeback behaviour over time
> and learn how it is impacting their performance.
>
>   # cat /proc/sys/vm/pages_dirtied
>   3747
>   # cat /proc/sys/vm/pages_entered_writeback
>   3618

Would it be better to have these values in /proc/vmstat
and /proc/zoneinfo ?

I don't really see why they need to be in /proc/sys
at all...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
