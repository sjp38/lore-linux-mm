Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6D2616B005A
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 21:01:09 -0400 (EDT)
Message-ID: <501F171F.50001@redhat.com>
Date: Sun, 05 Aug 2012 21:00:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/9] rbtree: add __rb_change_child() helper function
References: <1343946858-8170-1-git-send-email-walken@google.com> <1343946858-8170-4-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-4-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/02/2012 06:34 PM, Michel Lespinasse wrote:
> Add __rb_change_child() as an inline helper function to replace code that
> would otherwise be duplicated 4 times in the source.
>
> No changes to binary size or speed.
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
