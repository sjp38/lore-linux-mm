Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8336B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 01:49:43 -0400 (EDT)
Received: by oiag65 with SMTP id g65so106884789oia.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 22:49:42 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id h2si3470539obe.68.2015.03.20.22.49.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 22:49:42 -0700 (PDT)
Message-ID: <550D054A.9070808@huawei.com>
Date: Sat, 21 Mar 2015 13:44:42 +0800
From: Xie XiuQi <xiexiuqi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] tracing: add trace event for memory-failure
References: <1426734270-8146-1-git-send-email-xiexiuqi@huawei.com> <20150319103939.GD11544@pd.tnic> <550B9EF2.7000604@huawei.com> <3908561D78D1C84285E8C5FCA982C28F32A258C2@ORSMSX114.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32A258C2@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>
Cc: "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On 2015/3/21 1:24, Luck, Tony wrote:
>> RAS user space tools like rasdaemon which base on trace event, could
>> receive mce error event, but no memory recovery result event. So, I
>> want to add this event to make this scenario complete.
> 
> Excellent answer.  Are you going to write that patch for rasdaemon?

Yes, I will ;-)

> 
> -Tony
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
