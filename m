Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1297D6B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 15:07:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so101270199wmg.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 12:07:44 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id 204si6916075wmk.102.2016.10.04.12.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 12:07:42 -0700 (PDT)
Subject: Re: Frequent ext4 oopses with 4.4.0 on Intel NUC6i3SYB
References: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de>
 <20161004084136.GD17515@quack2.suse.cz>
 <90dfe18f-9fe7-819d-c410-cdd160644ab7@gmx.de>
 <2b7d6bd6-7d16-3c60-1b84-a172ba378402@gmx.de>
 <CABYiri-UUT6zVGyNENp-aBJDj6Oikodc5ZA27Gzq5-bVDqjZ4g@mail.gmail.com>
From: Johannes Bauer <dfnsonfsduifb@gmx.de>
Message-ID: <de0e04f0-3eb1-5224-fc13-5ce5ee654bb9@gmx.de>
Date: Tue, 4 Oct 2016 21:02:27 +0200
MIME-Version: 1.0
In-Reply-To: <CABYiri-UUT6zVGyNENp-aBJDj6Oikodc5ZA27Gzq5-bVDqjZ4g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Korolyov <andrey@xdel.ru>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On 04.10.2016 20:45, Andrey Korolyov wrote:
> On Tue, Oct 4, 2016 at 8:32 PM, Johannes Bauer <dfnsonfsduifb@gmx.de> wrote:
>> On 04.10.2016 18:50, Johannes Bauer wrote:
>>
>>> Uhh, that sounds painful. So I'm following Ted's advice and building
>>> myself a 4.8 as we speak.
>>
>> Damn bad idea to build on the instable target. Lots of gcc segfaults and
>> weird stuff, even without a kernel panic. The system appears to be
>> instable as hell. Wonder how it can even run and how much of the root fs
>> is already corrupted :-(
>>
>> Rebuilding 4.8 on a different host.
> 
> Looks like a platform itself is somewhat faulty: [1].

Thanks for the hint, I'll post there as well. The device is less than 4
weeks old, so it's still under full warranty. Maybe it really is the HW
and I'll return it.

> Also please bear
> in mind that standalone memory testers would rather not expose certain
> classes of memory failures, I`d suggest to test allocator`s work
> against gcc runs on tmpfs, almost same as you did before. Frequency of
> crashes due to wrong pointer contents of an fs cache is most probably
> a direct outcome from its relative memory footprint.

I will and did, but strangely some kernel building on /dev/shm worked
really nice. I Ctrl-Ced, rebooted for good measure and rsynced the 4.8.0
on the device. Then, I tried to update-initramfs:

nuc [/lib/modules]: update-initramfs -u
update-initramfs: Generating /boot/initrd.img-4.4.0-21-generic
modinfo: ERROR: could not get modinfo from 'qla3xxx': Invalid argument
Segmentation fault
Segmentation fault
modinfo: ERROR: could not get modinfo from 'mpt3sas': Invalid argument
modinfo: ERROR: could not get modinfo from 'pktcdvd': No such file or
directory
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
Bus error
[...]
Segmentation fault
Segmentation fault
Segmentation fault
Segmentation fault
update-initramfs: failed for /boot/initrd.img-4.4.0-21-generic with 139.

update-initramfs causes heavy disk I/O, so really maybe it's something
with the disk driver. As of now I really can't get 4.8.0 to even get to
a point where it'd be bootable.

I'll continue fighting on all fronts and report as soon as I learn more.
Thanks for the help, it is very much appreciated.

Cheers,
Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
