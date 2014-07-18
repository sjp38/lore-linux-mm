Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 09EDC6B0036
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 14:01:15 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so3274880qaq.15
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:01:14 -0700 (PDT)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id a50si11954054qgf.6.2014.07.18.11.01.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 11:01:14 -0700 (PDT)
Received: by mail-qc0-f181.google.com with SMTP id w7so3594626qcr.40
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:01:14 -0700 (PDT)
Date: Fri, 18 Jul 2014 14:01:10 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/2] Memoryless nodes and kworker
Message-ID: <20140718180110.GD13012@htj.dyndns.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
 <20140718112039.GA8383@htj.dyndns.org>
 <CAOhV88PyBK3WxDjG1H0hUbRhRYzPOzV8eim5DuOcgObe-FtFYg@mail.gmail.com>
 <20140718180008.GC13012@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140718180008.GC13012@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jul 18, 2014 at 02:00:08PM -0400, Tejun Heo wrote:
> This isn't a huge issue but it shows that this is the wrong layer to
> deal with this issue.  Let the allocators express where they are.
                                 ^
				 allocator users
> Choosing and falling back belong to the memory allocator.  That's the
> only place which has all the information that's necessary and those
> details must be contained there.  Please don't leak it to memory
> allocator users.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
