Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 48A826B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 21:13:36 -0400 (EDT)
Message-ID: <501F1A24.60505@redhat.com>
Date: Sun, 05 Aug 2012 21:13:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/9] rbtree: place easiest case first in rb_erase()
References: <1343946858-8170-1-git-send-email-walken@google.com> <1343946858-8170-5-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-5-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/02/2012 06:34 PM, Michel Lespinasse wrote:
> In rb_erase, move the easy case (node to erase has no more than
> 1 child) first. I feel the code reads easier that way.
>
> Signed-off-by: Michel Lespinasse<walken@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
