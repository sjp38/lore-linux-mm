Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id D9BEE6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 13:21:10 -0400 (EDT)
Message-ID: <4F96E102.9000904@redhat.com>
Date: Tue, 24 Apr 2012 13:21:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
References: <4F96CDE1.5000909@redhat.com> <4F96D27A.2050005@gmail.com> <4F96DFE0.6040306@redhat.com>
In-Reply-To: <4F96DFE0.6040306@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/24/2012 01:16 PM, Larry Woodman wrote:
> On 04/24/2012 12:19 PM, KOSAKI Motohiro wrote:

>> Please use
>>
>> /*
>> * foo bar
>> */
>>
>> style comment. and this comment only explain how code work but don't
>> explain why.
>> I hope the comment describe HPC usecase require to migrate if src and
>> dest have the
>> same weight.

> How does this look:

Still does not explain the "why"...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
