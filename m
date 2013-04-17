Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 708C16B0037
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 02:52:34 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro12so731436pbb.4
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 23:52:33 -0700 (PDT)
Date: Tue, 16 Apr 2013 23:52:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug fix PATCH v3] Reusing a resource structure allocated by
 bootmem
In-Reply-To: <516E452A.7060703@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1304162351300.5220@chino.kir.corp.google.com>
References: <516DEC34.7040008@jp.fujitsu.com> <alpine.DEB.2.02.1304161733340.14583@chino.kir.corp.google.com> <516E2305.3060705@jp.fujitsu.com> <alpine.DEB.2.02.1304162144320.3493@chino.kir.corp.google.com> <516E452A.7060703@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hp.com, linuxram@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Apr 2013, Yasuaki Ishimatsu wrote:

> > How much memory are we talking about?
> 
> Hmm. I don't know correctly.
> 
> Here is kernel message of my system. The message is shown by mem_init().
> 

Do you have an estimate on the amount of struct resource memory that will 
be leaked if entire pages won't be freed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
