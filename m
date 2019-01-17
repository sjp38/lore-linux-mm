Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 024688E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 11:29:15 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d31so9610513qtc.4
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 08:29:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u4si315473qkc.197.2019.01.17.08.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 08:29:14 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
Date: Thu, 17 Jan 2019 11:29:10 -0500
In-Reply-To: <20190116181859.D1504459@viggo.jf.intel.com> (Dave Hansen's
	message of "Wed, 16 Jan 2019 10:18:59 -0800")
Message-ID: <x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, thomas.lendacky@amd.com, mhocko@suse.com, linux-nvdimm@lists.01.org, tiwai@suse.de, ying.huang@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, baiyaowei@cmss.chinamobile.com, zwisler@kernel.org, bhelgaas@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org

Dave Hansen <dave.hansen@linux.intel.com> writes:

> Persistent memory is cool.  But, currently, you have to rewrite
> your applications to use it.  Wouldn't it be cool if you could
> just have it show up in your system like normal RAM and get to
> it like a slow blob of memory?  Well... have I got the patch
> series for you!

So, isn't that what memory mode is for?
  https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/

Why do we need this code in the kernel?

-Jeff
