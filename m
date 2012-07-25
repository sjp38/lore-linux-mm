Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 400036B0068
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 14:00:53 -0400 (EDT)
Message-ID: <501033F7.9090002@redhat.com>
Date: Wed, 25 Jul 2012 13:59:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] rbtree: remove prior augmented rbtree implementation
References: <1342787467-5493-1-git-send-email-walken@google.com> <1342787467-5493-7-git-send-email-walken@google.com> <20120724015505.GB9690@google.com>
In-Reply-To: <20120724015505.GB9690@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/23/2012 09:55 PM, Michel Lespinasse wrote:
> convert arch/x86/mm/pat_rbtree.c to the proposed augmented rbtree api
> and remove the old augmented rbtree implementation.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>


I'm looking forward to using your new augmented rbtree
code for the rbtree based arch_get_unmapped_area code.
It should provide a nice speedup on munmap.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
