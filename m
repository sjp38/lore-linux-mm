Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBCD6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:25:21 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p63so64087758wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 03:25:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id df5si21517703wjb.118.2016.01.29.03.25.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 03:25:20 -0800 (PST)
Subject: Re: [linux-next:master 1875/2100] include/linux/jump_label.h:122:2:
 error: implicit declaration of function 'atomic_read'
References: <201601291512.vqk4lpvV%fengguang.wu@intel.com>
 <56AB3EEB.8090808@suse.cz> <20160129215335.1a049964@canb.auug.org.au>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AB4C1D.5090801@suse.cz>
Date: Fri, 29 Jan 2016 12:25:17 +0100
MIME-Version: 1.0
In-Reply-To: <20160129215335.1a049964@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: kbuild test robot <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kbuild-all@01.org, linux-s390@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>

On 01/29/2016 11:53 AM, Stephen Rothwell wrote:
> Hi Vlastimil,
> 
> On Fri, 29 Jan 2016 11:28:59 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:
>> >    include/linux/jump_label.h: In function 'static_key_count':  
>> >>> include/linux/jump_label.h:122:2: error: implicit declaration of function 'atomic_read' [-Werror=implicit-function-declaration]  
>> >      return atomic_read(&key->enabled);  
>> 
>> Sigh.
>> 
>> I don't get it, there's "#include <linux/atomic.h>" in jump_label.h right before
>> it gets used. So, what implicit declaration?
> 
> But we are in the process of reading linux/atomic.h already, and the
> #include in jump_label.h will just not read it then (because of the
> include guards) so the body of linux/atomic.h has not yet been read
> when we process static_key_count().  i.e. we have a circular inclusion.
 
Oh, of course, doh. Thanks.

Please replace the -fix with this patch. Sorry again.

----8<----
