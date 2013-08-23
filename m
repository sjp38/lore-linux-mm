Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6072B6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 00:45:00 -0400 (EDT)
Date: Thu, 22 Aug 2013 21:46:39 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] [BUGFIX] drivers/base: fix show_mem_removable section
 count
Message-ID: <20130823044639.GA27413@kroah.com>
References: <20130823023837.GA12396@sgi.com>
 <20130823041045.GB12296@kroah.com>
 <20130823041750.GA3081@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130823041750.GA3081@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Thu, Aug 22, 2013 at 11:17:50PM -0500, Russ Anderson wrote:
> On Thu, Aug 22, 2013 at 09:10:45PM -0700, Greg Kroah-Hartman wrote:
> > On Thu, Aug 22, 2013 at 09:38:38PM -0500, Russ Anderson wrote:
> > > "cat /sys/devices/system/memory/memory*/removable" crashed the system.
> > 
> > On what kernels?  linux-next or Linus's tree, or 3.10.y?
> 
> Linus 3.11-rc6

So 3.10 is ok?  Trying to figure out where to send the fix to, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
