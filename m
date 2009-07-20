Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C563B6B005D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 14:37:27 -0400 (EDT)
Message-ID: <4A64B964.2080307@redhat.com>
Date: Mon, 20 Jul 2009 14:37:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] ksm: prevent mremap move poisoning
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com> <1247851850-4298-7-git-send-email-ieidus@redhat.com> <1247851850-4298-8-git-send-email-ieidus@redhat.com> <1247851850-4298-9-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-9-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> KSM's scan allows for user pages to be COWed or unmapped at any time,
> without requiring any notification.  But its stable tree does assume
> that when it finds a KSM page where it placed a KSM page, then it is
> the same KSM page that it placed there.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
