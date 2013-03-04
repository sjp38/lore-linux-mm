Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id CE2586B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 04:52:24 -0500 (EST)
Received: by mail-wi0-f194.google.com with SMTP id hm11so832692wib.5
        for <linux-mm@kvack.org>; Mon, 04 Mar 2013 01:52:23 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 4 Mar 2013 17:52:22 +0800
Message-ID: <CAAO_Xo7sEH5W_9xoOjax8ynyjLCx7GBpse+EU0mF=9mEBFhrgw@mail.gmail.com>
Subject: Inactive memory keep growing and how to release it?
From: Lenky Gao <lenky.gao@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

When i just run a test on Centos 6.2 as follows:

#!/bin/bash

while true
do

	file="/tmp/filetest"

	echo $file

	dd if=/dev/zero of=${file} bs=512 count=204800 &> /dev/null

	sleep 5
done

the inactive memory keep growing:

#cat /proc/meminfo | grep Inactive\(fi
Inactive(file):   420144 kB
...
#cat /proc/meminfo | grep Inactive\(fi
Inactive(file):   911912 kB
...
#cat /proc/meminfo | grep Inactive\(fi
Inactive(file):  1547484 kB
...

and i cannot reclaim it:

# cat /proc/meminfo | grep Inactive\(fi
Inactive(file):  1557684 kB
# echo 3 > /proc/sys/vm/drop_caches
# cat /proc/meminfo | grep Inactive\(fi
Inactive(file):  1520832 kB

I have tested on other version kernel, such as 2.6.30 and .6.11, the
problom also exists.

When in the final situation, i cannot kmalloc a larger contiguous
memory, especially in interrupt context.
Can you give some tips to avoid this?

PS:
# uname -a
Linux localhost.localdomain 2.6.32-220.el6.x86_64 #1 SMP Tue Dec 6
19:48:22 GMT 2011 x86_64 x86_64 x86_64 GNU/Linux



--
Regards,

Lenky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
