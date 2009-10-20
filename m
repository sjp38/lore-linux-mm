Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8019B6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 23:28:13 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n9K3S8F2004282
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 04:28:08 +0100
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by spaceape9.eur.corp.google.com with ESMTP id n9K3RfbF025018
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 20:28:06 -0700
Received: by pzk38 with SMTP id 38so3770502pzk.9
        for <linux-mm@kvack.org>; Mon, 19 Oct 2009 20:28:05 -0700 (PDT)
Date: Mon, 19 Oct 2009 20:28:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/5] Documentation: ABI: document
 /sys/devices/system/cpu/
In-Reply-To: <20091019213435.32729.81751.stgit@bob.kio>
Message-ID: <alpine.DEB.1.00.0910192022460.25264@chino.kir.corp.google.com>
References: <20091019212740.32729.7171.stgit@bob.kio> <20091019213435.32729.81751.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: akpm@linux-foundation.org, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Oct 2009, Alex Chiang wrote:

> diff --git a/Documentation/ABI/testing/sysfs-devices-cpu b/Documentation/ABI/testing/sysfs-devices-cpu
> new file mode 100644
> index 0000000..9070889
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-devices-cpu

Shouldn't this be called sysfs-devices-system-cpu?

I see what you're doing: /sys/devices/system/node/* files are contained in 
sysfs-devices-memory, but I think it would be helpful to have a more 
strict naming scheme so that the contents of a sysfs directory are 
described by a file of the same name.

> @@ -0,0 +1,42 @@
> +What:		/sys/devices/system/cpu/
> +Date:		October 2009
> +Contact:	Linux kernel mailing list <linux-kernel@vger.kernel.org>
> +Description:
> +		A collection of CPU attributes, including cache information,
> +		topology, and frequency. It also contains a mechanism to
> +		logically hotplug CPUs.
> +
> +		The actual attributes present are architecture and
> +		configuration dependent.
> +
> +
> +What:		/sys/devices/system/cpu/$cpu/online

cpu# ?

> +Date:		January 2006
> +Contact:	Linux kernel mailing list <linux-kernel@vger.kernel.org>
> +Description:
> +		When CONFIG_HOTPLUG_CPU is enabled, allows the user to
> +		discover and change the online state of a CPU. To discover
> +		the state:

This is present even without CONFIG_HOTPLUG_CPU.

> +
> +		cat /sys/devices/system/cpu/$cpu/online
> +
> +		A value of 0 indicates the CPU is offline. A value of 1
> +		indicates it is online. To change the state, echo the
> +		desired new state into the file:
> +
> +		echo [0|1] > /sys/devices/system/cpu/$cpu/online
> +
> +		For more information, please read Documentation/cpu-hotplug.txt
> +
> +
> +What:		/sys/devices/system/cpu/$cpu/node
> +Date:		October 2009
> +Contact:	Linux memory management mailing list <linux-mm@kvack.org>
> +Description:
> +		When CONFIG_NUMA is enabled, a symbolic link that points
> +		to the corresponding NUMA node directory.
> +
> +		For example, the following symlink is created for cpu42
> +		in NUMA node 2:
> +
> +		/sys/devices/system/cpu/cpu42/node2 -> ../../node/node2
> 


Would it be possible for you to document all entities in 
/sys/devices/system/cpu/* in this new file (requiring a folding of 
Documentation/ABI/testing/sysfs-devices-cache_disable into it)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
