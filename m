Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BE97D6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 16:47:41 -0400 (EDT)
Date: Tue, 20 Oct 2009 14:47:38 -0600
From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH 5/5] Documentation: ABI: document
	/sys/devices/system/cpu/
Message-ID: <20091020204738.GC23675@ldl.fc.hp.com>
References: <20091019212740.32729.7171.stgit@bob.kio> <20091019213435.32729.81751.stgit@bob.kio> <alpine.DEB.1.00.0910192022460.25264@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0910192022460.25264@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com>:
> On Mon, 19 Oct 2009, Alex Chiang wrote:
> 
> > diff --git a/Documentation/ABI/testing/sysfs-devices-cpu b/Documentation/ABI/testing/sysfs-devices-cpu
> > new file mode 100644
> > index 0000000..9070889
> > --- /dev/null
> > +++ b/Documentation/ABI/testing/sysfs-devices-cpu
> 
> Shouldn't this be called sysfs-devices-system-cpu?
> 
> I see what you're doing: /sys/devices/system/node/* files are contained in 
> sysfs-devices-memory, but I think it would be helpful to have a more 
> strict naming scheme so that the contents of a sysfs directory are 
> described by a file of the same name.

Yeah, I was just trying to follow an earlier example. But you're
right, since I'm creating a brand new file, I can do it the Right
Way (tm).

> > @@ -0,0 +1,42 @@
> > +What:		/sys/devices/system/cpu/
> > +Date:		October 2009
> > +Contact:	Linux kernel mailing list <linux-kernel@vger.kernel.org>
> > +Description:
> > +		A collection of CPU attributes, including cache information,
> > +		topology, and frequency. It also contains a mechanism to
> > +		logically hotplug CPUs.
> > +
> > +		The actual attributes present are architecture and
> > +		configuration dependent.
> > +
> > +
> > +What:		/sys/devices/system/cpu/$cpu/online
> 
> cpu# ?

Sure, will change (depending on response to my earlier email).

> > +Date:		January 2006
> > +Contact:	Linux kernel mailing list <linux-kernel@vger.kernel.org>
> > +Description:
> > +		When CONFIG_HOTPLUG_CPU is enabled, allows the user to
> > +		discover and change the online state of a CPU. To discover
> > +		the state:
> 
> This is present even without CONFIG_HOTPLUG_CPU.

That's what I get for not checking. Thank you for correcting me.

> > +
> > +		cat /sys/devices/system/cpu/$cpu/online
> > +
> > +		A value of 0 indicates the CPU is offline. A value of 1
> > +		indicates it is online. To change the state, echo the
> > +		desired new state into the file:
> > +
> > +		echo [0|1] > /sys/devices/system/cpu/$cpu/online
> > +
> > +		For more information, please read Documentation/cpu-hotplug.txt
> > +
> > +
> > +What:		/sys/devices/system/cpu/$cpu/node
> > +Date:		October 2009
> > +Contact:	Linux memory management mailing list <linux-mm@kvack.org>
> > +Description:
> > +		When CONFIG_NUMA is enabled, a symbolic link that points
> > +		to the corresponding NUMA node directory.
> > +
> > +		For example, the following symlink is created for cpu42
> > +		in NUMA node 2:
> > +
> > +		/sys/devices/system/cpu/cpu42/node2 -> ../../node/node2
> > 
> 
> 
> Would it be possible for you to document all entities in 
> /sys/devices/system/cpu/* in this new file (requiring a folding of 
> Documentation/ABI/testing/sysfs-devices-cache_disable into it)?
 
I'll give it a go. There are quite a few things in that directory
though, like topology information, frequency, etc. that I wasn't
so excited about documenting.

But if that's the tax to create my new symlinks, I'll pay it. ;)

Thanks for the review,
/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
