Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C28DD6B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 20:17:23 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d18so36996469pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 17:17:23 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q18si3186241pge.19.2017.02.28.17.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 17:17:23 -0800 (PST)
Subject: Re: [PATCH 0/5] mm: support parallel free of memory
References: <20170224114036.15621-1-aaron.lu@intel.com>
 <20170228163947.cbd83e48dcb149c697b316cd@linux-foundation.org>
 <b20b53b5-346e-3558-2260-44b3d111636b@intel.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <31665668-9885-6045-a314-8c092800c739@intel.com>
Date: Wed, 1 Mar 2017 09:17:26 +0800
MIME-Version: 1.0
In-Reply-To: <b20b53b5-346e-3558-2260-44b3d111636b@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Ying Huang <ying.huang@intel.com>

On 03/01/2017 08:43 AM, Dave Hansen wrote:
> On 02/28/2017 04:39 PM, Andrew Morton wrote:
>> Dumb question: why not do this in userspace, presumably as part of the
>> malloc() library?  malloc knows where all the memory is and should be
>> able to kick off N threads to run around munmapping everything?
> 
> One of the places we saw this happen was when an app crashed and was
> exit()'ing under duress without cleaning up nicely.  The time that it
> takes to unmap a few TB of 4k pages is pretty excessive.
 
Thanks Dave for the answer, I should have put this in the changelog(will
do that in the next revision). Sorry about this Andrew, I hope Dave's
answer clears things up about the patch's intention.

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
