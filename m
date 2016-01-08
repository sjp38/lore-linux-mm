Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 8F210828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 14:13:07 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id v14so279343420ykd.3
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 11:13:07 -0800 (PST)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id f124si5238029ywa.147.2016.01.08.11.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jan 2016 11:13:06 -0800 (PST)
Received: by mail-yk0-x232.google.com with SMTP id k129so350255145yke.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 11:13:06 -0800 (PST)
Date: Fri, 8 Jan 2016 14:13:05 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 5/5] x86, acpi, cpu-hotplug: Set persistent cpuid <->
 nodeid mapping when booting.
Message-ID: <20160108191305.GA1898@mtj.duckdns.org>
References: <1452140425-16577-1-git-send-email-tangchen@cn.fujitsu.com>
 <1452140425-16577-6-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452140425-16577-6-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: cl@linux.com, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hello, Tang.

On Thu, Jan 07, 2016 at 12:20:25PM +0800, Tang Chen wrote:
> From: Gu Zheng <guz.fnst@cn.fujitsu.com>
> 
> This patch finishes step 4.

This doesn't help people trying to read the patch.  If you wanna say
it's one of the steps of something, you also need to say what the
steps are.  No need to duplicate the whole thing but a short summary
would be helpful.

> This patch set the persistent cpuid <-> nodeid mapping for all enabled/disabled
> processors at boot time via an additional acpi namespace walk for processors.

So, the patchset generally looks good to me although I'm not too
familiar with acpi.  Rafael, Len, what do you think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
