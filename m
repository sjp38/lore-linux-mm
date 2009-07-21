Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8BE3B6B005A
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 14:18:44 -0400 (EDT)
Message-ID: <4A660630.2060801@redhat.com>
Date: Tue, 21 Jul 2009 21:17:20 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/10] ksm: identify PageKsm pages
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com> <1247851850-4298-7-git-send-email-ieidus@redhat.com> <20090721175139.GE2239@random.random> <4A660101.3000307@redhat.com> <20090721180059.GG2239@random.random>
In-Reply-To: <20090721180059.GG2239@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Jul 21, 2009 at 01:55:13PM -0400, Rik van Riel wrote:
>   
>> I guess that if they are to remain unswappable, they
>> should go onto the unevictable list.
>>     
>
> They should indeed. Not urgent but it will optimize the vm (as in
> virtual memory) cpu load a bit.
>
>   
>> Then again, I'm guessing this is all about to change
>> in not too much time :)
>>     
>
> That's my point, current implementation of PageKsm don't seem to last
> long, and if we keep logic the same it'll likely happen soon that
> PageKsm != PageAnon on a Ksm page. So I'd rather keep it different
> even now, given I doubt it's moving the needle anywhere in ksm code.
>   
Hugh mentioned that he specially moved the ksm pages to be anonymous 
beacuse he felt it is more right...
About PageExternal(): If I understand right, you both want to see the 
ksm pages swapped in the same way:
try_to_unmap() will call the stable tree as rmap walker to know what 
ptes it should unpresent,
but while probably Hugh wanted to allow such thing only for ksm (using 
PageKsm()) you probably talking about PageExternal() that will work with
modified function pointers and will let any driver register for such 
usage...,

So if it is PageKsm() or PageExtrnal() probably related to whatever you 
allow such rmap walking just for ksm or for every driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
