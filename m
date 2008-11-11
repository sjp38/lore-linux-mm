Message-ID: <491A0F17.2070706@redhat.com>
Date: Wed, 12 Nov 2008 01:02:47 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] add ksm kernel shared memory driver
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>	<1226409701-14831-2-git-send-email-ieidus@redhat.com>	<1226409701-14831-3-git-send-email-ieidus@redhat.com>	<1226409701-14831-4-git-send-email-ieidus@redhat.com>	<20081111150345.7fff8ff2@bike.lwn.net>	<491A0483.3010504@redhat.com> <20081111153028.422b301a@bike.lwn.net>
In-Reply-To: <20081111153028.422b301a@bike.lwn.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

Jonathan Corbet wrote:
>
> What about things like cache effects from scanning all those pages?  My
> guess is that, if you're trying to run dozens of Windows guests, cache
> usage is not at the top of your list of concerns, but I could be
> wrong.  Usually am...
>   

Ok, ksm does make the cache of the cpu dirty when scanning the pages
(but the scanning happen slowly slowly and cache usually get dirty much 
faster)
But infact it improve the cache by the fact that it make many ptes point 
to the same page
so if before we had 12 process touching 12 diffrent physical page they 
would dirty the page
but now they will touch just one...

so i guess it depend on how you see it...

> Thanks,
>
> jon
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
