Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BCD476B00DB
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 17:03:47 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so4538561pad.30
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 14:03:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id mj9si6088451pab.306.2013.10.25.14.03.46
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 14:03:46 -0700 (PDT)
Date: Fri, 25 Oct 2013 21:03:44 +0000 (UTC)
From: "Artem S. Tashkinov" <t.artem@lycos.com>
Message-ID: <476525596.14731.1382735024280.JavaMail.mail@webmail11>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <20131025214952.3eb41201@notabene.brown>
 <alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
 <154617470.12445.1382725583671.JavaMail.mail@webmail11><20131026074349.0adc9646@notabene.brown>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: neilb@suse.de
Cc: david@lang.hm, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

Oct 26, 2013 02:44:07 AM, neil wrote:
On Fri, 25 Oct 2013 18:26:23 +0000 (UTC) "Artem S. Tashkinov"
>> 
>> Exactly. And not being able to use applications which show you IO performance
>> like Midnight Commander. You might prefer to use "cp -a" but I cannot imagine
>> my life without being able to see the progress of a copying operation. With the current
>> dirty cache there's no way to understand how you storage media actually behaves.
>
>So fix Midnight Commander.  If you want the copy to be actually finished when
>it says  it is finished, then it needs to call 'fsync()' at the end.

This sounds like a very bad joke. How applications are supposed to show and
calculate an _average_ write speed if there are no kernel calls/ioctls to actually
make the kernel flush dirty buffers _during_ copying? Actually it's a good way to
solve this problem in user space - alas, even if such calls are implemented, user
space will start using them only in 2018 if not further from that.

>> 
>> Per device dirty cache seems like a nice idea, I, for one, would like to disable it
>> altogether or make it an absolute minimum for things like USB flash drives - because
>> I don't care about multithreaded performance or delayed allocation on such devices -
>> I'm interested in my data reaching my USB stick ASAP - because it's how most people
>> use them.
>>
>
>As has already been said, you can substantially disable  the cache by tuning
>down various values in /proc/sys/vm/.
>Have you tried?

I don't understand who you are replying to. I asked about per device settings, you are
again referring me to system wide settings - they don't look that good if we're talking
about a 3MB/sec flash drive and 500MB/sec SSD drive. Besides it makes no sense
to allocate 20% of physical RAM for things which don't belong to it in the first place.

I don't know any other OS which has a similar behaviour.

And like people (including me) have already mentioned, such a huge dirty cache can
stall their PCs/servers for a considerable amount of time.

Of course, if you don't use Linux on the desktop you don't really care - well, I do. Also
not everyone in this world has an UPS - which means such a huge buffer can lead to a
serious data loss in case of a power blackout.

Regards,

Artem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
