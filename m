Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3622F6B004D
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:49:24 -0400 (EDT)
Message-ID: <4F6B7431.8080701@redhat.com>
Date: Thu, 22 Mar 2012 14:49:21 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
References: <4F6B6BFF.1020701@redhat.com> <4F6B7358.60800@gmail.com>
In-Reply-To: <4F6B7358.60800@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Motohiro Kosaki <mkosaki@redhat.com>

On 03/22/2012 02:45 PM, KOSAKI Motohiro wrote:
> CC to Christoph.
>
>
Sorry Christoph I meant to cc you on the original message!

Larry

> Wait.
>
> This may be non-optimal for cpusets, but maybe optimal migrate_pages, 
> especially
> the usecase is HPC. I guess this is intended behavior. I think we need 
> to hear
> Christoph's intention.
>
> But, I'm not against this if he has no objection.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
