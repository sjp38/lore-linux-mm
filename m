Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5EBA46B005A
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 13:38:56 -0400 (EDT)
Message-ID: <4A64ABA2.4010200@redhat.com>
Date: Mon, 20 Jul 2009 13:38:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/10] ksm: the mm interface to ksm
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-5-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Michael Kerrisk <mtk.manpages@gmail.com>
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> This patch presents the mm interface to a dummy version of ksm.c,
> for better scrutiny of that interface: the real ksm.c follows later.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
