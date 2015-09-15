Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 08F686B0255
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 18:02:58 -0400 (EDT)
Received: by qgez77 with SMTP id z77so156893083qge.1
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 15:02:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l9si17838657qhl.13.2015.09.15.15.02.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 15:02:57 -0700 (PDT)
Date: Tue, 15 Sep 2015 15:02:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] fs: global sync to not clear error status of
 individual inodes
Message-Id: <20150915150254.6c78985cb271c7104b3ee717@linux-foundation.org>
In-Reply-To: <20150915143723.GA1747@two.firstfloor.org>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
	<20150915095412.GD13399@xzibit.linux.bs1.fc.nec.co.jp>
	<20150915143723.GA1747@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Junichi Nomura <j-nomura@ce.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Tue, 15 Sep 2015 16:37:24 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> > This patch adds filemap_fdatawait_keep_errors() for call sites where
> > writeback error is not handled so that they don't clear error status.
> 
> Patch looks good to me. 
> 

Me too.

It would be nice to capture the test case(s) somewhere permanent. 
Possibly in tools/testing/selftests, but selftests is more for peculiar
linux-specific things.  LTP or xfstests would be a better place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
