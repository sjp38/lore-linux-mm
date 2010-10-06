Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A9366B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 22:30:15 -0400 (EDT)
Received: by qwb8 with SMTP id 8so127669qwb.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 19:29:58 -0700 (PDT)
Message-ID: <4CABDF0E.3050400@vflare.org>
Date: Tue, 05 Oct 2010 22:29:34 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: OOM panics with zram
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1284053081.7586.7910.camel@nimitz> <4CA8CE45.9040207@vflare.org> <20101005234300.GA14396@kroah.com>
In-Reply-To: <20101005234300.GA14396@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/5/2010 7:43 PM, Greg KH wrote:
> On Sun, Oct 03, 2010 at 02:41:09PM -0400, Nitin Gupta wrote:
>> Also, please do not use linux-next/mainline version of compcache. Instead
>> just use version in the project repository here:
>> hg clone https://compcache.googlecode.com/hg/ compcache 
> 
> What?  No, the reason we put this into the kernel was so that _everyone_
> could work on it, including the original developers.  Going off and
> doing development somewhere else just isn't ok.  Should I just delete
> this driver from the staging tree as you don't seem to want to work with
> the community at this point in time?
>

Getting it out of -staging wasn't my intent. Community is the reason
that this project still exists.


>> This is updated much more frequently and has many more bug fixes over
>> the mainline. It will also be easier to fix bugs/add features much more
>> quickly in this repo rather than sending them to lkml which can take
>> long time.
> 
> Yes, developing in your own sandbox can always be faster, but there is
> no feedback loop.
> 

I was finding it real hard to find time to properly discuss each patch
over LKML, so I thought of shifting focus to local project repository
and then later go through proper reviews.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
