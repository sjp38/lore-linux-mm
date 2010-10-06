Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B015D6B006A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 00:30:50 -0400 (EDT)
Received: by qyk33 with SMTP id 33so4676646qyk.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 21:30:47 -0700 (PDT)
Message-ID: <4CABFB6F.2070800@vflare.org>
Date: Wed, 06 Oct 2010 00:30:39 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: OOM panics with zram
References: <1281374816-904-1-git-send-email-ngupta@vflare.org> <1284053081.7586.7910.camel@nimitz> <4CA8CE45.9040207@vflare.org> <20101005234300.GA14396@kroah.com> <4CABDF0E.3050400@vflare.org> <20101006023624.GA27685@kroah.com>
In-Reply-To: <20101006023624.GA27685@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 10/5/2010 10:36 PM, Greg KH wrote:
> On Tue, Oct 05, 2010 at 10:29:34PM -0400, Nitin Gupta wrote:
>> On 10/5/2010 7:43 PM, Greg KH wrote:
>>> On Sun, Oct 03, 2010 at 02:41:09PM -0400, Nitin Gupta wrote:
>>>> Also, please do not use linux-next/mainline version of compcache. Instead
>>>> just use version in the project repository here:
>>>> hg clone https://compcache.googlecode.com/hg/ compcache 
>>>
>>> What?  No, the reason we put this into the kernel was so that _everyone_
>>> could work on it, including the original developers.  Going off and
>>> doing development somewhere else just isn't ok.  Should I just delete
>>> this driver from the staging tree as you don't seem to want to work with
>>> the community at this point in time?
>>>
>>
>> Getting it out of -staging wasn't my intent. Community is the reason
>> that this project still exists.
>>
>>
>>>> This is updated much more frequently and has many more bug fixes over
>>>> the mainline. It will also be easier to fix bugs/add features much more
>>>> quickly in this repo rather than sending them to lkml which can take
>>>> long time.
>>>
>>> Yes, developing in your own sandbox can always be faster, but there is
>>> no feedback loop.
>>>
>>
>> I was finding it real hard to find time to properly discuss each patch
>> over LKML, so I thought of shifting focus to local project repository
>> and then later go through proper reviews.
> 
> So, should I delete the version in staging, or are you going to send
> patches to sync it up with your development version?
> 

Deleting it from staging would not help much. Much more helpful would
be to sync at least the mainline and linux-next version of the driver
so it's easier to develop against these kernel trees.  Initially, I
thought -staging means that any reviewed change can quickly make it
to *both* linux-next and more importantly -staging in mainline. Working/
Testing against mainline is much smoother than against linux-next.

Thanks,
Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
