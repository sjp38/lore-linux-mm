Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id BDF126B004A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 16:11:09 -0400 (EDT)
Message-ID: <4F9708D9.5060500@redhat.com>
Date: Tue, 24 Apr 2012 16:11:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
References: <4F96CDE1.5000909@redhat.com> <4F96D27A.2050005@gmail.com> <4F96DFE0.6040306@redhat.com> <alpine.DEB.2.00.1204241317170.26005@router.home> <4F97082B.9040903@redhat.com>
In-Reply-To: <4F97082B.9040903@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Motohiro Kosaki <mkosaki@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/24/2012 04:08 PM, Larry Woodman wrote:
> On 04/24/2012 02:17 PM, Christoph Lameter wrote:
>> On Tue, 24 Apr 2012, Larry Woodman wrote:
>>
>>> How does this look:
>>
>> Could you please send the patches inline? Its difficult to quote the
>> attachment.
>>
>
> Sorry all of these email clients are different.

Neither the comment or the changelog explains why you want
to make this change.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
