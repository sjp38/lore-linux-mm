Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7E6B66B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 19:45:24 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so11270903pde.0
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:45:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id x3si3745357pbk.53.2014.02.13.16.45.23
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 16:45:23 -0800 (PST)
Date: Thu, 13 Feb 2014 16:45:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
Message-Id: <20140213164521.c656b6022287f387dddd5a2f@linux-foundation.org>
In-Reply-To: <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
References: <52F4B8A4.70405@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402071239301.4212@chino.kir.corp.google.com>
	<52F88C16.70204@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402100200420.30650@chino.kir.corp.google.com>
	<52F8C556.6090006@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com>
	<52FC6F2A.30905@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com>
	<52FC98A6.1000701@linux.vnet.ibm.com>
	<alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com>
	<20140214001438.GB1651@linux.vnet.ibm.com>
	<CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 13 Feb 2014 16:37:53 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:

>  unsigned long max_sane_readahead(unsigned long nr)
>  {
>         return min(nr, 128);
>  }

I bet nobody will notice.

It should be 128*4096/PAGE_CACHE_SIZE so that variations in PAGE_SIZE
don't affect readahead behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
