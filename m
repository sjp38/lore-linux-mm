Date: Mon, 11 Feb 2008 09:54:25 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
Message-ID: <20080211175425.GA28300@kroah.com>
References: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2008 at 09:23:18AM -0800, Badari Pulavarty wrote:
> Hi Andrew,
> 
> While testing hotplug memory remove against -mm, I noticed
> that unregister_memory() is not cleaning up /sysfs entries
> correctly. It also de-references structures after destroying
> them (luckily in the code which never gets used). So, I cleaned
> up the code and fixed the extra reference issue.
> 
> Could you please include it in -mm ?

Want me to add this to my tree and send it in my next update for the
driver core to Linus?

I'll be glad to do that.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
