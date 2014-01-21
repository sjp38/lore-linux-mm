Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 793ED6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:38:25 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so8041539pab.17
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 23:38:25 -0800 (PST)
Received: from zill.ext.symas.net (zill.ext.symas.net. [69.43.206.106])
        by mx.google.com with ESMTPS id i3si4176353pbe.319.2014.01.20.23.38.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 23:38:23 -0800 (PST)
Message-ID: <52DE23E8.9010608@symas.com>
Date: Mon, 20 Jan 2014 23:38:16 -0800
From: Howard Chu <hyc@symas.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] [ATTEND] Persistent memory
References: <CALCETrUaotUuzn60-bSt1oUb8+94do2QgiCq_TXhqEHj79DePQ@mail.gmail.com> <52D8AEBF.3090803@symas.com> <52D982EB.6010507@amacapital.net>
In-Reply-To: <52D982EB.6010507@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Andy Lutomirski wrote:
> On 01/16/2014 08:17 PM, Howard Chu wrote:
>> Andy Lutomirski wrote:
>>> I'm interested in a persistent memory track.  There seems to be plenty
>>> of other emails about this, but here's my take:
>>
>> I'm also interested in this track. I'm not up on FS development these
>> days, the last time I wrote filesystem code was nearly 20 years ago. But
>> persistent memory is a topic near and dear to my heart, and of great
>> relevance to my current pet project, the LMDB memory-mapped database.
>>
>> In a previous era I also developed block device drivers for
>> battery-backed external DRAM disks. (My ideal would have been systems
>> where all of RAM was persistent. I suppose we can just about get there
>> with mobile phones and tablets these days.)
>>
>> In the context of database engines, I'm interested in leveraging
>> persistent memory for write-back caching and how user level code can be
>> made aware of it. (If all your cache is persistent and guaranteed to
>> eventually reach stable store then you never need to fsync() a
>> transaction.)
>
> Hmm.  Presumably that would work by actually allocating cache pages in
> persistent memory.  I don't think that anything like the current XIP
> interfaces can do that, but it's certainly an interesting thought for
> (complicated) future work.
>
> This might not be pretty in conjunction with something like my
> writethrough mapping idea -- read(2) and write(2) would be fine (well,
> write(2) might need to use streaming loads), but mmap users who weren't
> expecting it might have truly awful performance.  That especially
> includes things like databases that aren't expecting this behavior.

At the moment all I can suggest is a new mmap() flag, e.g. MAP_PERSISTENT. Not 
sure how a user or app should discover that it's supported though.
>
> --Andy
>
>>
>>> First, I'm not an FS expert.  I've never written an FS, touched an
>>> on-disk (or on-persistent-memory) FS format.  I have, however, mucked
>>> with some low-level x86 details, and I'm a heavy abuser of the Linux
>>> page cache.
>>>
>>> I'm an upcoming user of persistent memory -- I have some (in the form
>>> if NV-DIMMs) and I have an application (HFT and a memory-backed
>>> database thing) that I'll port to run on pmfs or ext4 w/ XIP once
>>> everything is ready.
>>>
>>> I'm also interested in some of the implementation details.  For this
>>> stuff to be reliable on anything resembling commodity hardware, there
>>> will be some caching issues to deal with.  For example, I think it
>>> would be handy to run things like pmfs on top of write-through
>>> mappings.  This is currently barely supportable (and only using
>>> mtrrs), but it's not terribly complicated (on new enough hardware) to
>>> support real write-through PAT entries.
>>>
>>> I've written an i2c-imc driver (currently in limbo on the i2c list),
>>> which will likely be used for control operations on NV-DIMMs plugged
>>> into Intel-based server boards.
>>>
>>> In principle, I could even bring a working NV-DIMM system to the
>>> summit -- it's nearby, and this thing isn't *that* large :)
>>>
>>> --Andy
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe
>>> linux-fsdevel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>
>


-- 
   -- Howard Chu
   CTO, Symas Corp.           http://www.symas.com
   Director, Highland Sun     http://highlandsun.com/hyc/
   Chief Architect, OpenLDAP  http://www.openldap.org/project/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
