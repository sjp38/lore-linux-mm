Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 2F6316B0069
	for <linux-mm@kvack.org>; Thu, 30 Aug 2012 17:42:08 -0400 (EDT)
Message-ID: <503FDE96.3040702@redhat.com>
Date: Thu, 30 Aug 2012 17:43:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] rbtree based interval tree as a prio_tree replacement
References: <1344324343-3817-1-git-send-email-walken@google.com> <20120830143401.be06d61b.akpm@linux-foundation.org>
In-Reply-To: <20120830143401.be06d61b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/30/2012 05:34 PM, Andrew Morton wrote:

> It would good to have solid acknowledgement from Rik that this approach
> does indeed suit his pending vma changes.

It does. Michel's rbtree rework is exactly what I need.

I do not need the interval tree bits, but the faster
augmented rbtree is required for my vma changes to
no longer have the performance regression Johannes
measured with a kernel build.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
