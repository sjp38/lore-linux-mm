Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 55CEA6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 22:17:36 -0400 (EDT)
Received: by qku63 with SMTP id 63so19225305qku.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 19:17:36 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.227])
        by mx.google.com with ESMTP id f2si677483qkh.53.2015.05.06.19.17.35
        for <linux-mm@kvack.org>;
        Wed, 06 May 2015 19:17:35 -0700 (PDT)
Date: Wed, 6 May 2015 22:17:45 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 0/3] tracing: add trace event for memory-failure
Message-ID: <20150506221745.3478fd92@grimm.local.home>
In-Reply-To: <20150507011207.GC7745@hori1.linux.bs1.fc.nec.co.jp>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
	<5540BD13.1010408@huawei.com>
	<20150507011207.GC7745@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Xie XiuQi <xiexiuqi@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@redhat.com" <mingo@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On Thu, 7 May 2015 01:12:07 +0000
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Wed, Apr 29, 2015 at 07:14:27PM +0800, Xie XiuQi wrote:
> > Hi Naoya,
> > 
> > Could you help to review and applied this series if possible.
> 
> Sorry for late response, I was offline for several days due to national
> holidays.
> 
> This patchset is good to me, but I'm not sure which path it should go through.
> Ordinarily, memory-failure patches go to linux-mm, but patch 3 depends on
> TRACE_DEFINE_ENUM patches, so this can go to linux-next directly, or go to
> linux-mm with depending patches.
> 
> Steven, Andrew, which way do you like?
> 

The TRACE_DEFINE_ENUM() patch set went into the 4.1 merge window. It
should be fine to base off of any of Linus's tags after or including
4.1-rc1.

I need to start converting other trace events for 4.2.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
