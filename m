Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j03IPlCO135784
	for <linux-mm@kvack.org>; Mon, 3 Jan 2005 13:25:47 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j03IPlHb348648
	for <linux-mm@kvack.org>; Mon, 3 Jan 2005 11:25:47 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j03IPlAv007594
	for <linux-mm@kvack.org>; Mon, 3 Jan 2005 11:25:47 -0700
Subject: Re: page migration
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <41D98556.8050605@sgi.com>
References: <41D98556.8050605@sgi.com>
Content-Type: text/plain
Date: Mon, 03 Jan 2005 10:25:33 -0800
Message-Id: <1104776733.25994.11.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-01-03 at 11:48 -0600, Ray Bryant wrote:
> The attached tar file contains a version of the mhp3 patch with the following
> properties:
> 
> (1)  It splits out the memory migration patches into a separate series file.
> (2)  The remaining patches are in the hotplug directory with its own
>        series files.
> (3)  Rollup patches for the two sets of patches are included.
> 
> If one applies the memory_migration patches first, the result compiles and
> links but I admit I have not tested it.

Very cool, thanks for doing this.  

> I've been unable to get (either) memory hotplug patch to compile.  It won't
> compile for Altix at all, because Altix requires NUMA.  I tried it on a
> Pentium machine, but apparently I didn't grab the correct config.

Hmmm.  Did you check the configs here?

	http://sr71.net/patches/2.6.10/2.6.10-rc2-mm4-mhp3/configs/

> Anyway, the fact that the diff shows the split out patches are equivalent
> to the full mhp3 patch should be good enough.
> 
> (The output of the comparison is included as the file reorder.diff).

That's good to know.

> I'd like to see this order of patches become the new order for the memory
> hotplug patch.  That way, I won't have to pull the migration patches out
> of the hotplug patch every time a new one comes out (I need the migration
> code, but not the hotplug code for a project I am working on.)
> 
> Do you suppose this can be done???

Absolutely.  I was simply working them in the order that they were
implemented.  But, if we want the migration stuff merged first, I have
absolutely no problem with putting it first in the patch set.  

Next time I publish a tree, I'll see what I can do about producing
similar rollups to what you have, with migration broken out from
hotplug.

Thanks again for doing all of this work.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
