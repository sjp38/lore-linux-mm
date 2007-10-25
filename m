Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PMjuCj029236
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:45:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PMjuuW132974
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:45:56 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PMjtpt013737
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:45:56 -0400
Subject: Re: [PATCH] Add "removable" to /sysfs to show memblock removability
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193351756.9894.30.camel@dyn9047017100.beaverton.ibm.com>
References: <1193351756.9894.30.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 15:45:54 -0700
Message-Id: <1193352354.24087.85.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 15:35 -0700, Badari Pulavarty wrote:
> 
> +static ssize_t show_mem_removable(struct sys_device *dev, char *buf)
> +{
> +       unsigned long start_pfn;
> +       struct memory_block *mem =
> +               container_of(dev, struct memory_block, sysdev);
> +
> +       start_pfn = section_nr_to_pfn(mem->phys_index);
> +       if (is_mem_section_removable(start_pfn, PAGES_PER_SECTION))
> +               return sprintf(buf, "True\n");
> +       else
> +               return sprintf(buf, "False\n");
> + 

Yeah, that's what I had in mind.  The only other thing I might suggest
would be to do a number instead of true/false here.  Just so that we
_can_ have scores in the future.  Otherwise fine with me.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
