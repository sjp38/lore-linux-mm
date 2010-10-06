Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E371E6B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:53:24 -0400 (EDT)
Received: by qyk4 with SMTP id 4so590033qyk.14
        for <linux-mm@kvack.org>; Wed, 06 Oct 2010 07:53:23 -0700 (PDT)
Message-ID: <4CAC8D5D.9000303@vflare.org>
Date: Wed, 06 Oct 2010 10:53:17 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: OOM panics with zram
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1284053081.7586.7910.camel@nimitz> <4CA8CE45.9040207@vflare.org> <20101005234300.GA14396@kroah.com> <4CABDF0E.3050400@vflare.org> <20101006023624.GA27685@kroah.com> <4CABFB6F.2070800@vflare.org> <AANLkTi=0bPudtyVzebvM0hZUB6DdDhjopB06FOww8hvt@mail.gmail.com> <20101006140343.GC19470@kroah.com> <4CAC84CF.3060902@kernel.org>
In-Reply-To: <4CAC84CF.3060902@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/6/2010 10:16 AM, Pekka Enberg wrote:
>  On 6.10.2010 17.03, Greg KH wrote:
>> Oops, I need to update the MAINTAINERS file, the proper place for the
>> staging tree is now in git, at
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-next-2.6.git
>>
>> which feeds directly into the linux-next tree.
> 
> Excellent! Nitin, can you develop and test zram against this tree?
> 

This seems like the ideal tree to develop against.

Thanks!
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
