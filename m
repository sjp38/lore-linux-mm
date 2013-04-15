From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] staging: ramster: add how-to for ramster
Date: Mon, 15 Apr 2013 09:02:57 +0800
Message-ID: <22357.2715338834$1365987795@news.gmane.org>
References: <1365983816-30204-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130415000804.GA15244@kroah.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1URXpA-0001jQ-Uv
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Apr 2013 03:03:13 +0200
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 54AF76B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 21:03:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Apr 2013 10:54:10 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id EA7D12CE804A
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 11:03:03 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3F0nR5w54394920
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 10:49:31 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3F130Pf000586
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 11:03:00 +1000
Content-Disposition: inline
In-Reply-To: <20130415000804.GA15244@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Sun, Apr 14, 2013 at 05:08:04PM -0700, Greg Kroah-Hartman wrote:
>On Mon, Apr 15, 2013 at 07:56:56AM +0800, Wanpeng Li wrote:
>> +This is a how-to document for RAMster.  It applies to the March 9, 2013
>> +version of RAMster, re-merged with the new zcache codebase, built and tested
>> +on the 3.9 tree and submitted for the staging tree for 3.9.
>
>This is not needed at all, given that it should just reflect the state
>of the code in the kernel that this file is present in.  Please remove
>it.
>
>> +Note that this document was created from notes taken earlier.  I would
>> +appreciate any feedback from anyone who follows the process as described
>> +to confirm that it works and to clarify any possible misunderstandings,
>> +or to report problems.
>
>Is this needed?

Ok, I will fix all the issues in this doc and repost them. ;-)

Regards,
Wanpeng Li 

>
>> +A. PRELIMINARY
>> +
>> +1) Install two or more Linux systems that are known to work when upgraded
>> +   to a recent upstream Linux kernel version (e.g. v3.9).  I used Oracle
>> +   Linux 6 ("OL6") on two Dell Optiplex 790s.  Note that it should be possible
>> +   to use ocfs2 as a filesystem on your systems but this hasn't been
>> +   tested thoroughly, so if you do use ocfs2 and run into problems, please
>> +   report them.  Up to eight nodes should work, but not much testing has
>> +   been done with more than three nodes.
>> +
>> +On each system:
>> +
>> +2) Configure, build and install then boot Linux (e.g. 3.9), just to ensure it
>> +   can be done with an unmodified upstream kernel.  Confirm you booted
>> +   the upstream kernel with "uname -a".
>> +
>> +3) Install ramster-tools.  The src.rpm and an OL6 rpm are available
>> +   in this directory.  I'm not very good at userspace stuff and
>> +   would welcome any help in turning ramster-tools into more
>> +   distributable rpms/debs for a wider range of distros.
>
>This isn't true, the rpms are not here.
>
>> +B. BUILDING RAMSTER INTO THE KERNEL
>> +
>> +Do the following on each system:
>> +
>> +1) Ensure you have the new codebase for drivers/staging/zcache in your source.
>> +
>> +2) Change your .config to have:
>> +
>> +	CONFIG_CLEANCACHE=y
>> +	CONFIG_FRONTSWAP=y
>> +	CONFIG_STAGING=y
>> +	CONFIG_ZCACHE=y
>> +	CONFIG_RAMSTER=y
>> +
>> +   You may have to reconfigure your kernel multiple times to ensure
>> +   all of these are set properly.  I use:
>> +
>> +	# yes "" | make oldconfig
>> +
>> +   and then manually check the .config file to ensure my selections
>> +   have "taken".
>
>This last bit isn't needed at all.  Just stick to the "these are the
>settings you need enabled."
>
>> +   Do not bother to build the kernel until you are certain all of
>> +   the above config selections will stick for the build.
>> +
>> +3) Build this kernel and "make install" so that you have a new kernel
>> +   in /etc/grub.conf
>
>Don't assume 'make install' works for all distros, nor that
>/etc/grub.conf is a grub config file (hint, it usually isn't, and what
>about all the people not even using grub for their bootloader?)
>
>> +4) Add "ramster" to the kernel boot line in /etc/grub.conf.
>
>Again, drop grub.conf reference
>
>> +5) Reboot and check dmesg to ensure there are some messages from ramster
>> +   and that "ramster_enabled=1" appears.
>> +
>> +	# dmesg | grep ramster
>
>Are you sure ramster still spits out messages?  If so, provide an
>example of what it should look like.
>
>> +   You should also see a lot of files in:
>> +
>> +	# ls /sys/kernel/debug/zcache
>> +	# ls /sys/kernel/debug/ramster
>
>You forgot to mention that debugfs needs to be mounted.
>
>> +   and a few files in:
>> +
>> +	# ls /sys/kernel/mm/ramster
>> +
>> +   RAMster now will act as a single-system zcache but doesn't yet
>> +   know anything about the cluster so can't do anything remotely.
>> +
>> +C. BUILDING THE RAMSTER CLUSTER
>> +
>> +This is the error prone part unless you are a clustering expert.  We need
>> +to describe the cluster in /etc/ramster.conf file and the init scripts
>> +that parse it are extremely picky about the syntax.
>> +
>> +1) Create the /etc/ramster.conf file and ensure it is identical
>> +   on both systems.  There is a good amount of similar documentation
>> +   for ocfs2 /etc/cluster.conf that can be googled for this, but I use:
>> +
>> +	cluster:
>> +		name = ramster
>> +		node_count = 2
>> +	node:
>> +		name = system1
>> +		cluster = ramster
>> +		number = 0
>> +		ip_address = my.ip.ad.r1
>> +		ip_port = 7777
>> +	node:
>> +		name = system2
>> +		cluster = ramster
>> +		number = 0
>> +		ip_address = my.ip.ad.r2
>> +		ip_port = 7777
>> +
>> +   You must ensure that the "name" field in the file exactly matches
>> +   the output of "hostname" on each system.  The following assumes
>> +   you use "ramster" as the name of your cluster.
>> +
>> +2) Enable the ramster service and configure it:
>> +
>> +	# chkconfig --add ramster
>> +	# service ramster configure
>
>That's a huge assumption as to how your system config/startup scripts
>work, right?  Not all the world is using old-style system V init
>anymore, what about systemd?  openrc?
>
>greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
