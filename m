Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4D42B6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 05:50:51 -0400 (EDT)
Message-ID: <4A015C69.7010600@redhat.com>
Date: Wed, 06 May 2009 12:46:17 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses registrations.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <4A00DD4F.8010101@redhat.com>
In-Reply-To: <4A00DD4F.8010101@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, hugh@veritas.com, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Izik Eidus wrote:
>> subjects say it all.
>
> Not a very useful commit message.
>
> This makes me wonder, though.
>
> What happens if a user mmaps a 30MB memory region, registers it
> with KSM and then unmaps the middle 10MB?

User cant break 30MB into smaller one.
That mean that when you regisiter memory region that is X mb size, you 
can only remove it (as a whole), or add new region.
This should answer the next question you had about why i have just the 
start address for removing the regions.

>
>> Signed-off-by: Izik Eidus <ieidus@redhat.com>
>
> except for the commit message, Acked-by: Rik van Riel <riel@redhat.com>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
