Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5572A6B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 22:42:26 -0400 (EDT)
Received: by vcbfl17 with SMTP id fl17so2333523vcb.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 19:42:24 -0700 (PDT)
Message-ID: <4EB0AE0E.8040709@vflare.org>
Date: Tue, 01 Nov 2011 22:42:22 -0400
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com> <20110909203447.GB19127@kroah.com> <4E6ACE5B.9040401@vflare.org> <4E6E18C6.8080900@linux.vnet.ibm.com> <4E6EB802.4070109@vflare.org> <4E6F7DA7.9000706@linux.vnet.ibm.com> <4E6FC8A1.8070902@vflare.org> <4E72284B.2040907@linux.vnet.ibm.com> <4E738B81.2070005@vflare.org 1320168615.15403.80.camel@nimitz> <e51b28f7-da4a-4c53-889d-4f12b8dd701a@default>
In-Reply-To: <e51b28f7-da4a-4c53-889d-4f12b8dd701a@default>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg KH <greg@kroah.com>, gregkh@suse.de, devel@driverdev.osuosl.org, cascardo@holoscopio.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brking@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com

On 11/01/2011 02:35 PM, Dan Magenheimer wrote:

>> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
>> Sent: Tuesday, November 01, 2011 11:30 AM
>> To: Nitin Gupta
>> Cc: Seth Jennings; Greg KH; gregkh@suse.de; devel@driverdev.osuosl.org; Dan Magenheimer;
>> cascardo@holoscopio.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org; brking@linux.vnet.ibm.com;
>> rcj@linux.vnet.ibm.com
>> Subject: Re: [PATCH v2 0/3] staging: zcache: xcfmalloc support
>>
>> On Fri, 2011-09-16 at 13:46 -0400, Nitin Gupta wrote:
>>> I think replacing allocator every few weeks isn't a good idea. So, I
>>> guess better would be to let me work for about 2 weeks and try the slab
>>> based approach.  If nothing works out in this time, then maybe xcfmalloc
>>> can be integrated after further testing.
>>
>> Hi Nitin,
>>
>> It's been about six weeks. :)
>>
>> Can we talk about putting xcfmalloc() in staging now?
> 
> FWIW, given that I am quoting "code rules!" to the gods of Linux
> on another lkml thread, I can hardly disagree here.
> 


I agree with you Dan. It took me really long to bring the new allocator
into some shape and still I'm not very confident that it's ready to be
integrated with zcache.

> If Nitin continues to develop his allocator and it proves
> better than xcfmalloc (and especially if it can replace
> zbud as well), we can consider replacing xcfmalloc later.
> Until zcache is promoted from staging, I think we have
> that flexibility.
> 


Agreed.  Though I still consider slab based design much better, having
already tried xcfmalloc like design much earlier in the project history,
I would still favor xcfmalloc integration since xvmalloc weakness with
>PAGE_SIZE/2 objects is probably too much to bear.


> (Shameless advertisement though:  The xcfmalloc allocator
> only applies to pages passed via frontswap, and on
> that other lkml thread lurk many people intent on shooting
> frontswap down.  So, frankly, I'd prefer time to be spent
> on benchmarking zcache rather than on arguing about
> allocators which, as things currently feel to me on that
> other lkml thread, is not unlike rearranging deck chairs
> on the Titanic. Half-:-).
> 
>


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
