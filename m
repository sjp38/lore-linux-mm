Subject: Re: [PATCH v3][RFC] hugetlb: add per-node nr_hugepages sysfs
	attribute
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070613152847.GO3798@us.ibm.com>
References: <20070611231008.GD14458@us.ibm.com>
	 <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
	 <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com>
	 <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com>
	 <20070612174503.GB3798@us.ibm.com> <20070612191347.GE11781@holomorphy.com>
	 <20070613000446.GL3798@us.ibm.com> <20070613152649.GN3798@us.ibm.com>
	 <20070613152847.GO3798@us.ibm.com>
Content-Type: text/plain
Date: Wed, 13 Jun 2007 14:23:47 -0400
Message-Id: <1181759027.6148.77.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Christoph Lameter <clameter@sgi.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-13 at 08:28 -0700, Nishanth Aravamudan wrote:
<snip>
> 
> commit 05a7edb8c909c674cdefb0323348825cf3e2d1d0
> Author: Nishanth Aravamudan <nacc@us.ibm.com>
> Date:   Thu Jun 7 08:54:48 2007 -0700
> 
> hugetlb: add per-node nr_hugepages sysfs attribute
> 
> Allow specifying the number of hugepages to allocate on a particular
> node. Our current global sysctl will try its best to put hugepages
> equally on each node, but htat may not always be desired. This allows
> the admin to control the layout of hugepage allocation at a finer level
> (while not breaking the existing interface). Add callbacks in the sysfs
> node registration and unregistration functions into hugetlb to add the
> nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Cc: William Lee Irwin III <wli@holomorphy.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Cc: Anton Blanchard <anton@sambar.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> ---
> Do the dummy function definitions need to be (void)0?
> 

<snip>

> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index aa0dc9b..e9f5928 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -5,6 +5,7 @@
>  
>  #include <linux/mempolicy.h>
>  #include <linux/shm.h>
> +#include <linux/sysdev.h>
>  #include <asm/tlbflush.h>
>  
>  struct ctl_table;
> @@ -23,6 +24,11 @@ void __unmap_hugepage_range(struct vm_area_struct *, unsigned long, unsigned lon
>  int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
>  int hugetlb_report_meminfo(char *);
>  int hugetlb_report_node_meminfo(int, char *);
> +int hugetlb_register_node(struct sys_device *);
> +void hugetlb_unregister_node(struct sys_device *);

The parameter type for the two functions above need to be "struct node".
You'll need to include <linux/node.h> after <linux/sysdev.h>, as well.
Otherwise, doesn't build.


<snip>

Still testing...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
