Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E004B6B02A5
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 21:25:06 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id 123-v6so9149015ywt.12
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 18:25:06 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w11-v6si28054823ywi.401.2018.11.05.18.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 18:25:06 -0800 (PST)
Date: Mon, 5 Nov 2018 18:24:51 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 02/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181106022451.jry6nty6zsnpwq5e@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-3-daniel.m.jordan@oracle.com>
 <736b23a4-cb32-7926-101a-9b6555e59b5e@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <736b23a4-cb32-7926-101a-9b6555e59b5e@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Mon, Nov 05, 2018 at 12:51:33PM -0800, Randy Dunlap wrote:
> On 11/5/18 8:55 AM, Daniel Jordan wrote:
> > diff --git a/init/Kconfig b/init/Kconfig
> > index 41583f468cb4..ed82f76ed0b7 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -346,6 +346,17 @@ config AUDIT_TREE
> >  	depends on AUDITSYSCALL
> >  	select FSNOTIFY
> >  
> > +config KTASK
> > +	bool "Multithread CPU-intensive kernel work"
> > +	depends on SMP
> > +	default y
> > +	help
> > +	  Parallelize CPU-intensive kernel work.  This feature is designed for
> > +          big machines that can take advantage of their extra CPUs to speed up
> > +	  large kernel tasks.  When enabled, kworker threads may occupy more
> > +          CPU time during these kernel tasks, but these threads are throttled
> > +          when other tasks on the system need CPU time.
> 
> Use tab + 2 spaces consistently for help text indentation, please.

Ok, will do.  Thanks for pointing it out.
