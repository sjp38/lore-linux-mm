Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8525A6B004D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 20:53:01 -0400 (EDT)
Message-ID: <4A00DF9B.1080501@redhat.com>
Date: Tue, 05 May 2009 20:53:47 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com>
In-Reply-To: <1241475935-21162-4-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> This patch change the KSM_REMOVE_MEMORY_REGION ioctl to be specific per
> memory region (instead of flushing all the registred memory regions inside
> the file descriptor like it happen now)
> 
> The previoes api was:
> user register memory regions using KSM_REGISTER_MEMORY_REGION inside the fd,
> and then when he wanted to remove just one memory region, he had to remove them
> all using KSM_REMOVE_MEMORY_REGION.
> 
> This patch change this beahivor by chaning the KSM_REMOVE_MEMORY_REGION
> ioctl to recive another paramter that it is the begining of the virtual
> address that is wanted to be removed.

This is different from munmap and madvise, which take both
start address and length.

Why?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
