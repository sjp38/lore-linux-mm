Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4108E6B009E
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 20:19:05 -0500 (EST)
Message-ID: <4B623757.7090001@redhat.com>
Date: Thu, 28 Jan 2010 20:18:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] change anon_vma linking to fix multi-process server
 	scalability issue
References: <20100128002000.2bf5e365@annuminas.surriel.com>	 <1264696641.17063.32.camel@barrios-desktop>	 <4B61C83A.20301@redhat.com> <28c262361001281655x70e5f77awf4d890d20f57ca83@mail.gmail.com>
In-Reply-To: <28c262361001281655x70e5f77awf4d890d20f57ca83@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 01/28/2010 07:55 PM, Minchan Kim wrote:
> On Fri, Jan 29, 2010 at 2:24 AM, Rik van Riel<riel@redhat.com>  wrote:

>> What am I overlooking?
>
> I also look at the code more detail and found me wrong.
> In mprotect case 6,  the importer is fixed as head of vmas while next
> is marched
> on forward. So anon_vma_clone is just called once at first time.
> So as what you said, It's no problem.
> Totally, my mistake. Sorry for that, Rik.

No problem.  I spent about a day and a half with a few pieces
of paper going over all this code, before deciding how to code
this :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
