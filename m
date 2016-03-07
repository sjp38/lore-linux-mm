Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9B56B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 15:58:15 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fl4so84543804pad.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 12:58:15 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id m17si31130096pfj.147.2016.03.07.12.58.14
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 12:58:14 -0800 (PST)
Date: Mon, 07 Mar 2016 15:58:10 -0500 (EST)
Message-Id: <20160307.155810.587016604208120674.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <56DDE783.8090009@oracle.com>
References: <56DDDA31.9090105@oracle.com>
	<CALCETrXXU0fs2ezq+Wn_kr4dZTO=0RJmt6b=XBSA-wM7W_9j9A@mail.gmail.com>
	<56DDE783.8090009@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: luto@amacapital.net, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Mon, 7 Mar 2016 13:41:39 -0700

> Shared data may not always be backed by a file. My understanding is
> one of the use cases is for in-memory databases. This shared space
> could also be used to hand off transactions in flight to other
> processes. These transactions in flight would not be backed by a
> file. Some of these use cases might not use shmfs even. Setting ADI
> bits at virtual address level catches all these cases since what backs
> the tagged virtual address can be anything - a mapped file, mmio
> space, just plain chunk of memory.

Frankly the most interesting use case to me is simply finding bugs
and memory scribbles, and for that we're want to be able to ADI
arbitrary memory returned from malloc() and friends.

I personally see ADI more as a debugging than a security feature,
but that's just my view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
