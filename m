Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EFA2A6B0093
	for <linux-mm@kvack.org>; Wed,  6 May 2009 09:56:40 -0400 (EDT)
Message-ID: <4A019719.7030504@redhat.com>
Date: Wed, 06 May 2009 16:56:41 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <20090506133434.GX16078@random.random>
In-Reply-To: <20090506133434.GX16078@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, May 06, 2009 at 12:16:52PM +0100, Hugh Dickins wrote:
>   
>
>> p.s.  I wish you'd chosen different name than KSM - the kernel
>> has supported shared memory for many years - and notice ksm.c itself
>> says "Memory merging driver".  "Merge" would indeed have been a less
>> ambiguous term than "Share", but I think too late to change that now
>> - except possibly in the MADV_ flag names?
>>     
>
> I don't actually care about names, so I leave this to other to discuss.
>   
Well, There is no real problem changing the name, any suggestions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
