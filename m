Date: Mon, 11 Feb 2008 11:48:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
Message-Id: <20080211114818.74c9dcc7.akpm@linux-foundation.org>
In-Reply-To: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
References: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, greg@kroah.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2008 09:23:18 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Hi Andrew,
> 
> While testing hotplug memory remove against -mm, I noticed
> that unregister_memory() is not cleaning up /sysfs entries
> correctly. It also de-references structures after destroying
> them (luckily in the code which never gets used). So, I cleaned
> up the code and fixed the extra reference issue.
> 
> Could you please include it in -mm ?
> 
> Thanks,
> Badari
> 
> register_memory()/unregister_memory() never gets called with
> "root". unregister_memory() is accessing kobject_name of
> the object just freed up. Since no one uses the code,
> lets take the code out. And also, make register_memory() static.  
> 
> Another bug fix - before calling unregister_memory()
> remove_memory_block() gets a ref on kobject. unregister_memory()
> need to drop that ref before calling sysdev_unregister().
> 

I'd say this:

> Subject: [-mm PATCH] register_memory/unregister_memory clean ups

is rather tame.  These are more than cleanups!  These sound like
machine-crashing bugs.  Do they crash machines?  How come nobody noticed
it?

All very strange...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
