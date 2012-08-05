Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 1025F6B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 16:47:43 -0400 (EDT)
Message-ID: <501EDBCD.6030208@redhat.com>
Date: Sun, 05 Aug 2012 16:47:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/9] rbtree test: fix sparse warning about 64-bit constant
References: <1343946858-8170-1-git-send-email-walken@google.com> <1343946858-8170-2-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/02/2012 06:34 PM, Michel Lespinasse wrote:
> Just a small fix to make sparse happy.
>
> Signed-off-by: Michel Lespinasse<walken@google.com>
> Reported-by: Fengguang Wu<wfg@linux.intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
