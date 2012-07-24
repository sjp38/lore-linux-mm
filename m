Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id D16956B0044
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 14:50:19 -0400 (EDT)
Message-ID: <500EEE60.4060507@redhat.com>
Date: Tue, 24 Jul 2012 14:50:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] rbtree: rb_erase updates and comments
References: <1342787467-5493-1-git-send-email-walken@google.com> <1342787467-5493-2-git-send-email-walken@google.com>
In-Reply-To: <1342787467-5493-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/20/2012 08:31 AM, Michel Lespinasse wrote:
> Minor updates to the rb_erase() function:
> - Reorder code to put simplest / common case (no more than 1 child) first.
> - Fetch the parent first, since it ends up being required in all 3 cases.
> - Add a few comments to illustrate case 2 (node to remove has 2 childs,
>    but one of them is the successor) and case 3 (node to remove has 2 childs,
>    successor is a left-descendant of the right child).
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
