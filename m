Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0DCCD6B0037
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 14:44:38 -0400 (EDT)
Received: from mailout-de.gmx.net ([10.1.76.29]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0Lo3XS-1UwW8j2lSa-00fymm for
 <linux-mm@kvack.org>; Fri, 15 Mar 2013 19:44:37 +0100
Message-ID: <51436C12.1040400@gmx.de>
Date: Fri, 15 Mar 2013 19:44:34 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
Subject: Re: SLUB + UML : WARNING: at mm/page_alloc.c:2386
References: <51422008.3020208@gmx.de> <CAFLxGvyzkSsUJQMefeB2PcVBykZNqCQe5k19k0MqyVr111848w@mail.gmail.com> <514239F7.3050704@gmx.de> <20130314212107.GA23056@redhat.com> <51424000.1030309@gmx.de> <CAFLxGvzcy_+2exNbbCGZ460Y417MjoChY39FPXvqaEOZTq8ofQ@mail.gmail.com>
In-Reply-To: <CAFLxGvzcy_+2exNbbCGZ460Y417MjoChY39FPXvqaEOZTq8ofQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, user-mode-linux-user@lists.sourceforge.net, Linux Kernel <linux-kernel@vger.kernel.org>, Davi Arnaut <davi.arnaut@gmail.com>

On 03/15/2013 12:10 AM, richard -rw- weinberger wrote:
> Time to look at UML's __get_user().


Just FWIW the "memdup_user:" debug-patch-line is not only triggered by trinity.
It happens even if I regularly boot a UML guest (stable Gentoo x86):



$ /usr/local/bin/linux-v3.9-rc2-292-ga2362d2 earlyprintk ubda=/home/tfoerste/virtual/uml/trinity ubdb=/mnt/ramdisk/swap_trinity eth0=tuntap,tap0,72:ef:3d:9f:c3:5a mem=768M con=pts con0=fd:0,fd:1 umid=uml 
Locating the bottom of the address space ... 0x1000
Locating the top of the address space ... 0xc0000000
Core dump limits :
        soft - NONE
        hard - NONE
Checking that ptrace can change system call numbers...OK
Checking syscall emulation patch for ptrace...OK
Checking advanced syscall emulation patch for ptrace...OK
Checking for tmpfs mount on /dev/shm...OK
Checking PROT_EXEC mmap in /dev/shm/...OK
Checking for the skas3 patch in the host:
  - /proc/mm...not found: No such file or directory
  - PTRACE_FAULTINFO...not found
  - PTRACE_LDT...not found
UML running in SKAS0 mode
Adding 9842688 bytes to physical memory to account for exec-shield gap
bootconsole [earlycon0] enabled
PID hash table entries: 4096 (order: 2, 16384 bytes)
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 768308k available
SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
NR_IRQS:15
Calibrating delay loop... 3461.12 BogoMIPS (lpj=17305600)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 512
Checking for host processor cmov support...Yes
Checking that host ptys support output SIGIO...Yes
Checking that host ptys support SIGIO on close...No, enabling workaround
memdup_user: 9
memdup_user: 9
devtmpfs: initialized
Using 2.6 host AIO
NET: Registered protocol family 16
bio: create slab <bio-0> at 0
Switching to clocksource itimer
NET: Registered protocol family 2
TCP established hash table entries: 8192 (order: 4, 65536 bytes)
TCP bind hash table entries: 8192 (order: 3, 32768 bytes)
TCP: Hash tables configured (established 8192 bind 8192)
TCP: reno registered
UDP hash table entries: 512 (order: 1, 8192 bytes)
UDP-Lite hash table entries: 512 (order: 1, 8192 bytes)
NET: Registered protocol family 1
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
mconsole (version 2) initialized on /home/tfoerste/.uml/uml/mconsole
Checking host MADV_REMOVE support...OK
UML Audio Relay (host dsp = /dev/sound/dsp, host mixer = /dev/sound/mixer)
Host TLS support detected
Detected host type: i386 (GDT indexes 6 to 9)
audit: initializing netlink socket (disabled)
type=2000 audit(1363372747.842:1): initialized
NFS: Registering the id_resolver key type
Key type id_resolver registered
Key type id_legacy registered
nfs4filelayout_init: NFSv4 File Layout Driver Registering...
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
msgmni has been set to 1500
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered (default)
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
TCP: cubic registered
NET: Registered protocol family 17
Key type dns_resolver registered
Initialized stdio console driver
Console initialized on /dev/tty0
                                console [tty0] enabled, bootconsole disabled
console [tty0] enabled, bootconsole disabled
                                            Initializing software serial port version 1
console [mc-1] enabled
 ubda: unknown partition table
 ubdb: unknown partition table
Netdevice 0 (72:ef:3d:9f:c3:5a) : 
TUN/TAP backend - 
memdup_user: 5
memdup_user: 10
EXT3-fs (ubda): error: couldn't mount because of unsupported optional features (240)
memdup_user: 5
memdup_user: 10
EXT2-fs (ubda): error: couldn't mount because of unsupported optional features (244)
memdup_user: 5
memdup_user: 10
EXT4-fs (ubda): INFO: recovery required on readonly filesystem
EXT4-fs (ubda): write access will be enabled during recovery
EXT4-fs (ubda): orphan cleanup on readonly fs
EXT4-fs (ubda): 60 orphan inodes deleted
EXT4-fs (ubda): recovery complete
EXT4-fs (ubda): mounted filesystem with ordered data mode. Opts: (null)
VFS: Mounted root (ext4 filesystem) readonly on device 98:0.
memdup_user: 9
memdup_user: 9
devtmpfs: mounted
memdup_user: 2
INIT: version 2.88 booting

   OpenRC 0.11.8 is starting up Gentoo Linux (i686) [UML]

 * Mounting /proc ...
memdup_user: 5
memdup_user: 5
 [ ok ]
 * Mounting /run ...
memdup_user: 6
memdup_user: 6
 * /run/openrc: creating directory
 * /run/lock: creating directory
 * /run/lock: correcting owner
 * Using /dev mounted from kernel ...
 [ ok ]
 * Mounting /dev/pts ...
memdup_user: 7
memdup_user: 7
 [ ok ]
 * Mounting /dev/shm ...
memdup_user: 6
memdup_user: 4
 [ ok ]
 * Mounting /sys ...
 [ ok ]
 * Mounting cgroup filesystem ...
 [ ok ]
 * Starting udev ...
 [ ok ]
 * Populating /dev with existing devices through uevents ...
 [ ok ]
 * Waiting for uevents to be processed ...
 [ ok ]
 * Setting up dm-crypt mappings ...
 *   crypt-swap using: -c aes -h sha1 -d /dev/urandom create crypt-swap /dev/ubdb ...
 [ ok ]
 *     pre_mount: mkswap ${dev} ...
 [ ok ]
 [ ok ]
 * Checking local filesystems  ...
stable: clean, 93039/122160 files, 318314/488281 blocks
 [ ok ]
 * Remounting root filesystem read/write ...


-- 
MfG/Sincerely
Toralf FA?rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
