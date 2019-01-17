Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3BC8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:48:53 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 4so6392972plc.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:48:53 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 64si2156169ply.372.2019.01.17.08.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 08:48:51 -0800 (PST)
Date: Thu, 17 Jan 2019 09:47:37 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
Message-ID: <20190117164736.GC31543@localhost.localdomain>
References: <20190116181859.D1504459@viggo.jf.intel.com>
 <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, thomas.lendacky@amd.com, fengguang.wu@intel.com, dave@sr71.net, linux-nvdimm@lists.01.org, tiwai@suse.de, zwisler@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, ying.huang@intel.com, bhelgaas@google.com, akpm@linux-foundation.org, bp@suse.de

On Thu, Jan 17, 2019 at 11:29:10AM -0500, Jeff Moyer wrote:
> Dave Hansen <dave.hansen@linux.intel.com> writes:
> > Persistent memory is cool.  But, currently, you have to rewrite
> > your applications to use it.  Wouldn't it be cool if you could
> > just have it show up in your system like normal RAM and get to
> > it like a slow blob of memory?  Well... have I got the patch
> > series for you!
> 
> So, isn't that what memory mode is for?
>   https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
> 
> Why do we need this code in the kernel?

I don't think those are the same thing. The "memory mode" in the link
refers to platforms that sequester DRAM to side cache memory access, where
this series doesn't have that platform dependency nor hides faster DRAM.
