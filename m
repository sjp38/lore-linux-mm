Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A95E46B005D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 14:36:01 -0400 (EDT)
Message-ID: <4A64B90E.2090509@redhat.com>
Date: Mon, 20 Jul 2009 14:35:58 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/10] ksm: Kernel SamePage Merging
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com> <1247851850-4298-7-git-send-email-ieidus@redhat.com> <1247851850-4298-8-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-8-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> From: Izik Eidus <ieidus@redhat.com>
> 
> Ksm is code that allows merging of identical pages between one or
> more applications, in a way invisible to the applications that use it.
> Pages that are merged are marked as read-only, then COWed when any
> application tries to change them.
> 
> Whereas fork() allows sharing anonymous pages between parent and child,
> ksm can share anonymous pages between unrelated processes.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
