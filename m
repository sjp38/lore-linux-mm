Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A34399000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 12:55:57 -0400 (EDT)
Message-ID: <4DFF7B99.2060909@redhat.com>
Date: Mon, 20 Jun 2011 12:55:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165035.GE20843@redhat.com>
In-Reply-To: <20110620165035.GE20843@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On 06/20/2011 12:50 PM, Andrea Arcangeli wrote:
> On Tue, Jun 21, 2011 at 12:34:28AM +0800, Amerigo Wang wrote:
>> transparent_hugepage=never should mean to disable THP completely,
>> otherwise we don't have a way to disable THP completely.
>> The design is broken.
>
> We want to allow people to boot with transparent_hugepage=never but to
> still allow people to enable it later at runtime. Not sure why you
> find it broken... Your patch is just crippling down the feature with
> no gain. There is absolutely no gain to disallow root to enable THP
> later at runtime with sysfs, root can enable it anyway by writing into
> /dev/mem.
>
> Unless you're root and you enable it, it's completely disabled, so I
> don't see what you mean it's not completely disabled. Not even
> khugepaged is started, try to grep of khugepaged...

Agreed, I don't really see the reason for these patches.

Amerigo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
