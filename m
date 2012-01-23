Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 810CE6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 13:57:40 -0500 (EST)
Received: by vcbfl11 with SMTP id fl11so2635033vcb.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 10:57:39 -0800 (PST)
Message-ID: <4F1DADA0.4030300@vflare.org>
Date: Mon, 23 Jan 2012 13:57:36 -0500
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] staging: zsmalloc: zsmalloc memory allocation library
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com> <1326149520-31720-2-git-send-email-sjenning@linux.vnet.ibm.com> <20120120141232.a7572919.akpm@linux-foundation.org>
In-Reply-To: <20120120141232.a7572919.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 01/20/2012 05:12 PM, Andrew Morton wrote:

> On Mon,  9 Jan 2012 16:51:56 -0600
> Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
>> This patch creates a new memory allocation library named
>> zsmalloc.
> 
> I haven't really begun to look at this yet.  The code is using many
> fields of struct page in new ways.  This is key information for anyone
> to effectively review the code.  So please carefully document (within
> the code itself) the ways in which the various page fields are used:
> semantic meaning of the overload, relationships between them, any
> locking rules or assumptions.  Ditto any other data structures.  This
> code should be reviewed very carefully by others so please implement it
> with that intention.
> 


> It appears that a pile of dead code will be generated if CPU hotplug is
> disabled.  (That's if it compiles at all!).  Please take a look at users
> of hotcpu_notifier() - this facility cunningly causes all the hotplug code
> to vanish from vmlinux if it is unneeded.
> 
>


ok, will look into these issues and add necessary documentation.

 
> afacit this code should be added to core mm/.  Addition of code like
> this to core mm/ will be fiercely resisted on principle!  Hence the
> (currently missing) justifications for adding it had best be good ones.
> 


I don't think this code should ever get into mm/ since its just a driver
specific allocator. However its used by more than one driver (zcache and
zram) so it may be moved to lib/ or drivers/zsmalloc atmost?

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
