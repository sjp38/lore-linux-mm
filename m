Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id EAF046B005A
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 17:52:30 -0400 (EDT)
Message-ID: <500F1917.2050308@redhat.com>
Date: Tue, 24 Jul 2012 17:52:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] rbtree: optimize fetching of sibling node
References: <1342787467-5493-1-git-send-email-walken@google.com> <1342787467-5493-3-git-send-email-walken@google.com>
In-Reply-To: <1342787467-5493-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/20/2012 08:31 AM, Michel Lespinasse wrote:
> When looking to fetch a node's sibling, we went through a sequence of:
> - check if node is the parent's left child
> - if it is, then fetch the parent's right child
>
> This can be replaced with:
> - fetch the parent's right child as an assumed sibling
> - check that node is NOT the fetched child
>
> This avoids fetching the parent's left child when node is actually
> that child. Saves a bit on code size, though it doesn't seem to make
> a large difference in speed.
>
> Signed-off-by: Michel Lespinasse<walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
