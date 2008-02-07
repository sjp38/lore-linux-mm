Date: Wed, 6 Feb 2008 16:03:28 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 2/3] hugetlb: add per-node nr_hugepages sysfs attribute
Message-ID: <20080207000328.GD16116@kroah.com>
References: <20080206231558.GI3477@us.ibm.com> <20080206231845.GJ3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080206231845.GJ3477@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2008 at 03:18:45PM -0800, Nishanth Aravamudan wrote:
> hugetlb: add per-node nr_hugepages sysfs attribute
> 
> Allow specifying the number of hugepages to allocate on a particular
> node. Our current global sysctl will try its best to put hugepages
> equally on each node, but htat may not always be desired. This allows
> the admin to control the layout of hugepage allocation at a finer level
> (while not breaking the existing interface).  Add callbacks in the sysfs
> node registration and unregistration functions into hugetlb to add the
> nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
> Greg, do I need to add documentation for this sysfs attribute to
> Documentation/ABI?

Yes, please.

> I'm not sure if I should just add a file in testing/ for just this
> attribute or should defer and create documentation for all of the
> /sys/devices/system/node information?

How about both for this one, and the existing ones?  That would be best.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
