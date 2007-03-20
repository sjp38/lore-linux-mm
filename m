Message-ID: <45FF33A5.7010909@redhat.com>
Date: Mon, 19 Mar 2007 21:06:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #2
References: <45FF3052.0@redhat.com>
In-Reply-To: <45FF3052.0@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Split the anonymous and file backed pages out onto their own pageout
> queues.  This we do not unnecessarily churn through lots of anonymous
> pages when we do not want to swap them out anyway.

> Please take this patch for a spin and let me know what goes well
> and what goes wrong.

In order to make testing easier, I have put some kernel RPMs
up on http://people.redhat.com/riel/vmsplit/

Any benchmark results are welcome, especially bad ones.
I want to make sure this thing runs as well as the current
VM in every situation, while also fixing the problems described
in my previous mail.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
