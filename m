Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 634FA6B038D
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:53:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x63so92394513pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:53:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e5si5706447plb.115.2017.03.16.08.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:53:41 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:53:35 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: fsx tests on DAX started to fail with msync failure on 0307
 -next tree
Message-ID: <20170316155335.GA27340@linux.intel.com>
References: <20170314025642.nwpf7zxbc6655gum@XZHOUW.usersys.redhat.com>
 <20170314173609.GA13885@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314173609.GA13885@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Xiong Zhou <xzhou@redhat.com>, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Mar 14, 2017 at 11:36:10AM -0600, Ross Zwisler wrote:
> On Tue, Mar 14, 2017 at 10:56:42AM +0800, Xiong Zhou wrote:
> > Hi,
> > 
> > xfstests cases:
> > generic/075 generic/112 generic/127 generic/231 generic/263
> > 
> > fail with DAX, pass without it. Both xfs and ext4.
> > 
> > It was okay on 0306 -next tree.
> 
> Thanks for the report.  I'm looking into it.  -next is all kinds of broken.
> :(

Just FYI, in case folks are still testing -next:

One other issue that I was hitting was that for many of the commits in -next
kernel modules wouldn't load, which meant that my /dev/pmem0 device wasn't
showing up because I have libnvdimm compiled as a module.

I bisected that issue to this commit:

commit d1091c7fa3d5 ("objtool: Improve detection of BUG() and other dead
ends")

It looks like Xiong also found this issue:

https://lkml.org/lkml/2017/3/2/114

And Linus found it:

https://lkml.org/lkml/2017/2/28/794

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
