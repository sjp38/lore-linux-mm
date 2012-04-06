Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4EF6B6B00F5
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:57:50 -0400 (EDT)
Message-ID: <4F7F3CA9.1030500@redhat.com>
Date: Fri, 06 Apr 2012 14:57:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V8] Eliminate task stack trace duplication
References: <1333737920-17555-1-git-send-email-yinghan@google.com>
In-Reply-To: <1333737920-17555-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/06/2012 02:45 PM, Ying Han wrote:
> The problem with small dmesg ring buffer like 512k is that only limited number
> of task traces will be logged. Sometimes we lose important information only
> because of too many duplicated stack traces. This problem occurs when dumping
> lots of stacks in a single operation, such as sysrq-T.
>
> This patch tries to reduce the duplication of task stack trace in the dump
> message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
> during bootup. Each time if we find the identical task trace in the task stack,
> we dump only the pid of the task which has the task trace dumped. So it is easy
> to back track to the full stack with the pid.

> Signed-off-by: Ying Han<yinghan@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
