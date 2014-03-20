Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id CB5046B01A4
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 05:19:07 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 200so1508707ykr.3
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 02:19:07 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j65si1421096yhe.17.2014.03.20.02.19.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 02:19:07 -0700 (PDT)
Message-ID: <532AB274.3030800@oracle.com>
Date: Thu, 20 Mar 2014 17:18:44 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: remove BUG_ON() from mlock_vma_page()
References: <1387327369-18806-1-git-send-email-bob.liu@oracle.com> <20140131123352.a3da2a1dee32d79ad1f6af9f@linux-foundation.org> <530A4CBE.5090305@oracle.com> <6B2BA408B38BA1478B473C31C3D2074E2F6DBA97C6@SV-EXCHANGE1.Corp.FC.LOCAL> <5314A9E9.6090802@suse.cz> <20140311184353.GA10764@redhat.com>
In-Reply-To: <20140311184353.GA10764@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "walken@google.com" <walken@google.com>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "stable@kernel.org" <stable@kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>


On 03/12/2014 02:43 AM, Dave Jones wrote:
> On Mon, Mar 03, 2014 at 05:12:25PM +0100, Vlastimil Babka wrote:
> 
>  > >> On 01/31/2014 03:33 PM, Andrew Morton wrote:
>  > >>> On Wed, 18 Dec 2013 08:42:49 +0800 Bob Liu<lliubbo@gmail.com>  wrote:
>  > >>>
>  > >>>>> This BUG_ON() was triggered when called from try_to_unmap_cluster()
>  > >>>>> which didn't lock the page.
>  > >>>>> And it's safe to mlock_vma_page() without PageLocked, so this patch
>  > >>>>> fix this issue by removing that BUG_ON() simply.
>  > >>>>>
>  > >>> This patch doesn't appear to be going anywhere, so I will drop it.
>  > >>> Please let's check to see whether the bug still exists and if so,
>  > >>> start another round of bugfixing.
>  > >>
>  > >> This bug still happens on the latest -next kernel.
>  > >
>  > > Yeah, I recognized it. I'm preparing new patch. Thanks.
>  > 
>  > What will be your approach? After we had the discussion some month ago 
>  > about m(un)lock vs migration I've concluded that there is no race that 
>  > page lock helps, and removing the BUG_ON() would be indeed correct. Just 
>  > needs to be correctly explained and documentation updated as well.
> 
> This is not just a -next problem btw, I just hit this in 3.14-rc6
> 

It seems the fix patch from Vlastimil was missed, I've resend it to Andrew.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
