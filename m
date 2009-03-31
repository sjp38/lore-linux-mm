Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E7C796B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 11:03:08 -0400 (EDT)
Date: Tue, 31 Mar 2009 17:02:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090331150218.GS9137@random.random>
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <1238457560-7613-2-git-send-email-ieidus@redhat.com> <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D22A9D.4050403@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 31, 2009 at 09:37:17AM -0500, Anthony Liguori wrote:
> In the very least, if you insist on not using sysfs, you should have a 
> separate character device that's used for control (like /dev/ksmctl).

I'm fine to use sysfs that's not the point, if you've to add a ksmctl
device, then sysfs is surely better. Besides ksm would normally be
enabled at boot, tasks jailed by selinux will better not start/stop
this thing.

If people wants /sys/kernel/mm/ksm instead of the start_stop ioctl we
surely can add it (provided there's a way to intercept write to the
sysfs file). Problem is registering memory could also be done with
'echo 0 -1 >/proc/self/ksm' and be inherited by childs, it's not just
start/stop. I mean this is more a matter of taste I'm
afraid... Personally I'm more concerned about the registering of the
ram API than the start/stop thing which I cannot care less about, so
my logic is that as long as this pseudodevice exists, we should use it
for everything. If we go away from it, then we should remove it as a
whole.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
