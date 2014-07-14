Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3E26B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 09:41:13 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so1622296wiw.0
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 06:41:12 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id gh11si10883117wic.86.2014.07.14.06.41.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jul 2014 06:41:10 -0700 (PDT)
Message-ID: <53C3DDE7.6000108@brockmann-consult.de>
Date: Mon, 14 Jul 2014 15:40:55 +0200
From: Peter Maloney <peter.maloney@brockmann-consult.de>
MIME-Version: 1.0
Subject: Re: kernel BUG - handle_mm_fault - Ubuntu 14.04 kernel 3.13.0-29-generic
References: <20140619163614.GA24297@node.dhcp.inet.fi>
In-Reply-To: <20140619163614.GA24297@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kamal Mostafa <kamal@canonical.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>


On 2014-06-19 18:36, Kirill A. Shutemov wrote:
> On Thu, Jun 19, 2014 at 06:10:11PM +0200, Peter Maloney wrote:
>> Hi, can someone please take a look at this and tell me what is going on?
>>
>> The event log reports no ECC errors.
>>
>> This machine was working fine with an older Ubuntu version, and has
>> failed this way twice since an upgrade 2 weeks ago.
>>
>> Symptoms include:
>>  - load goes up high, currently 1872.72
>>  - "ps -ef" hangs
>>  - this time I tested "echo w > /proc/sysrq-trigger" which made the
>> local shell and ssh hang, and ctrl+alt+del doesn't work, but machine
>> still responds to ping
>>
>> Please CC me; I'm not on the list.
>>
>> Thanks,
>> Peter
>>
>>
>>
>> Here's the log:
>>
>> Jun 12 15:42:42 node73 kernel: [17196.908781] ------------[ cut here
>> ]------------
>> Jun 12 15:42:42 node73 kernel: [17196.909789] kernel BUG at
>> /build/buildd/linux-3.13.0/mm/memory.c:3756!
> Looks like this:
>
> http://lkml.org/lkml/2014/5/8/275
>
> It seems the commit 107437febd49 has added to 3.13.11.3 "extended stable",
> but not in other -stable.
>
> Rik, should it be there too?
>
Hello again, I just wanted to say that I have built a kernel with this
fix on Jun 26, deployed it on the problem machines, and it has been
stable ever since.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
