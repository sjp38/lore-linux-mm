Received: by ug-out-1314.google.com with SMTP id s2so24594uge
        for <linux-mm@kvack.org>; Tue, 01 May 2007 03:28:35 -0700 (PDT)
Message-ID: <463715E8.1060903@googlemail.com>
Date: Tue, 01 May 2007 12:26:48 +0200
From: Gabriel C <nix.or.die@googlemail.com>
MIME-Version: 1.0
Subject: Re: pcmcia ioctl removal
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084623.GB14364@infradead.org> <Pine.LNX.4.64.0705010514300.9162@localhost.localdomain> <20070501094400.GX943@1wt.eu>
In-Reply-To: <20070501094400.GX943@1wt.eu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: "Robert P. J. Day" <rpjday@mindspring.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Willy Tarreau wrote:
> On Tue, May 01, 2007 at 05:16:13AM -0400, Robert P. J. Day wrote:
>   
>> On Tue, 1 May 2007, Christoph Hellwig wrote:
>>
>>     
>>>>  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
>>>>         
>>> ...
>>>
>>>       
>>>> Dominik is busy.  Will probably re-review and send these direct to Linus.
>>>>         
>>> The patch above is the removal of cardmgr support.  While I'd love
>>> to see this cruft gone it definitively needs maintainer judgement on
>>> whether they time has come that no one relies on cardmgr anymore.
>>>       
>> since i was the one who submitted the original patch to remove that
>> stuff, let me make an observation.
>>
>> when i submitted a patch to remove, for instance, the traffic shaper
>> since it's clearly obsolete, i was told -- in no uncertain terms --
>> that that couldn't be done since there had been no warning about its
>> impending removal.
>>
>> fair enough, i can accept that.
>>
>> on the other hand, the features removal file contains the following:
>>
>> ...
>> What:   PCMCIA control ioctl (needed for pcmcia-cs [cardmgr, cardctl])
>> When:   November 2005
>> ...
>>
>> in other words, the PCMCIA ioctl feature *has* been listed as obsolete
>> for quite some time, and is already a *year and a half* overdue for
>> removal.
>>
>> in short, it's annoying to take the position that stuff can't be
>> deleted without warning, then turn around and be reluctant to remove
>> stuff for which *more than ample warning* has already been given.
>> doing that just makes a joke of the features removal file, and makes
>> you wonder what its purpose is in the first place.
>>
>> a little consistency would be nice here, don't you think?
>>     
>
> No, it just shows how useless this file is. What is needed is a big
> warning during usage, not a file that nobody reads. Facts are :
>
>   - 90% of people here do not even know that this file exists
>   - 80% of the people who know about it do not consult it on a regular basis
>   - 80% of those who consult it on a regular basis are not concerned
>   - 75% of statistics are invented
>
> => only 20% of 20% of 10% of those who read LKML know that one feature
>    they are concerned about will soon be removed = 0.4% of LKML readers.
>
> If you put a warning in kernel messages (as I've seen for a long time
> about tcpdump using obsolete AF_PACKET), close to 100% of the users
> of the obsolete code who are likely to change their kernels will notice
> it.
>
>   

Hmm ? There is already a fat warning in dmesg for a long time now.


snip

...

pcmcia: Detected deprecated PCMCIA ioctl usage from process: discover.
pcmcia: This interface will soon be removed from the kernel; please 
expect breakage unless you upgrade to new tools.
pcmcia: see 
http://www.kernel.org/pub/linux/utils/kernel/pcmcia/pcmcia.html for details.

...


> I'm sorry for your patch which may get delayed a lot. You would spend
> fewer time stuffing warnings in areas affected by scheduled removal.
>
> BTW, I'm not even against the end of cardmgr support, it's just that
> I don't know what the alternative is, and I suspect that many users
> do not either. A big warning would have brought them to google who
> would have provided them with suggestions for alternatives.
>
> Willy
>
>
>   

Regards,

Gabriel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
