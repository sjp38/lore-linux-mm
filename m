Date: Mon, 19 Jan 2004 19:26:59 -0500 (EST)
From: Thomas Molina <tmolina@cablespeed.com>
Subject: Re: 2.6.1-mm4
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0401191912300.5662@localhost.localdomain>
References: <20040115225948.6b994a48.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rusty, 

I updated mm4 with the patch you sent in response to my shutdown oops 
report and haven't received a repeat oops in six reboots.  Hopefully this 
cures my problem.  I previously couldn't reproduce the oops every single 
reboot.  

I do have a couple of other anomalies to report though.

First is this snippet from my bootup log:

Cannot open master raw device '/dev/rawctl' (No such device)
/: clean, 192622/1196032 files, 969619/2390842 blocks
                                                           [  OK  ]
cat: /sys//devices/pci0000:00/0000:00:07.2/usb1/bNumConfigurations: No 
such file or directory
/etc/hotplug/usb.agent: line 144: [: too many arguments
Remounting root filesystem in read-write mode:             [  OK  ]
Activating swap partitions:                                [  OK  ]
Finding module dependencies:                               [  OK  ]

Second is that I receive the following error while compiling mm4:

Kernel: arch/i386/boot/bzImage is ready
sh /usr/local/kernel/linux-2.6.0/arch/i386/boot/install.sh 2.6.1-mm4a 
arch/i386/boot/bzImage System.map ""
WARNING: /lib/modules/2.6.1-mm4a/kernel/fs/nfsd/nfsd.ko needs unknown 
symbol dnotify_parent


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
