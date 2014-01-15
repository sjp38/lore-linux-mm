Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 78C9A6B0037
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:16:47 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so413131pab.20
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:16:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sw1si2078280pab.54.2014.01.14.17.16.45
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 17:16:46 -0800 (PST)
Date: Tue, 14 Jan 2014 17:16:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] hotplug, memory: move register_memory_resource out of the
 lock_memory_hotplug
Message-Id: <20140114171644.d7b97b0501708afbeae7c841@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1401141702450.3375@chino.kir.corp.google.com>
References: <1389723874-32372-1-git-send-email-nzimmer@sgi.com>
	<20140114151340.004d25c00056d88f33cadda0@linux-foundation.org>
	<alpine.DEB.2.02.1401141702450.3375@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Hedi <hedi@sgi.com>, Mike Travis <travis@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Jan 2014 17:05:42 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Tue, 14 Jan 2014, Andrew Morton wrote:
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: mm/memory_hotplug.c: register_memory_resource() fixes
> > 
> > - register_memory_resource() should not go BUG on ENOMEM.  That's
> >   appropriate at system boot time, but not at memory-hotplug time.  Fix.
> > 
> > - register_memory_resource()'s caller is incorrectly replacing
> >   request_resource()'s -EBUSY with -EEXIST.  Fix this by propagating
> >   errors appropriately.
> > 
> 
> Unfortunately, -EEXIST is a special case return value for both 
> acpi_memory_enable_device() and hv_mem_hot_add(), so they would need to be 
> modified to agree concurrently with this change.

blah, OK, thanks, I'll drop it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
