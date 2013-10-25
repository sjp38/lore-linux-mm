Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B210E6B00DD
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 14:26:27 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so4304577pdj.36
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 11:26:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.188])
        by mx.google.com with SMTP id gj2si5756558pac.254.2013.10.25.11.26.26
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 11:26:26 -0700 (PDT)
Date: Fri, 25 Oct 2013 18:26:23 +0000 (UTC)
From: "Artem S. Tashkinov" <t.artem@lycos.com>
Message-ID: <154617470.12445.1382725583671.JavaMail.mail@webmail11>
References: <160824051.3072.1382685914055.JavaMail.mail@webmail07>
 <20131025214952.3eb41201@notabene.brown><alpine.DEB.2.02.1310250425270.22538@nftneq.ynat.uz>
Subject: Re: Disabling in-memory write cache for x86-64 in Linux II
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@lang.hm
Cc: neilb@suse.de, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, axboe@kernel.dk, linux-mm@kvack.org

Oct 25, 2013 05:26:45 PM, david wrote:
On Fri, 25 Oct 2013, NeilBrown wrote:
>
>>
>> What exactly is bothering you about this?  The amount of memory used or the
>> time until data is flushed?
>
>actually, I think the problem is more the impact of the huge write later on.

Exactly. And not being able to use applications which show you IO performance
like Midnight Commander. You might prefer to use "cp -a" but I cannot imagine
my life without being able to see the progress of a copying operation. With the current
dirty cache there's no way to understand how you storage media actually behaves.

Hopefully this issue won't dissolve into obscurity and someone will actually make
up a plan (and a patch) how to make dirty write cache behave in a sane manner
considering the fact that there are devices with very different write speeds and
requirements. It'd be ever better, if I could specify dirty cache as a mount option
(though sane defaults or semi-automatic values based on runtime estimates
won't hurt).

Per device dirty cache seems like a nice idea, I, for one, would like to disable it
altogether or make it an absolute minimum for things like USB flash drives - because
I don't care about multithreaded performance or delayed allocation on such devices -
I'm interested in my data reaching my USB stick ASAP - because it's how most people
use them.

Regards,

Artem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
