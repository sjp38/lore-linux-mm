Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE1CB6B038A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 19:43:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id b5so8980558pfa.5
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:43:46 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g6si3115640pfk.140.2017.02.28.16.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 16:43:45 -0800 (PST)
Subject: Re: [PATCH 0/5] mm: support parallel free of memory
References: <20170224114036.15621-1-aaron.lu@intel.com>
 <20170228163947.cbd83e48dcb149c697b316cd@linux-foundation.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b20b53b5-346e-3558-2260-44b3d111636b@intel.com>
Date: Tue, 28 Feb 2017 16:43:45 -0800
MIME-Version: 1.0
In-Reply-To: <20170228163947.cbd83e48dcb149c697b316cd@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Ying Huang <ying.huang@intel.com>

On 02/28/2017 04:39 PM, Andrew Morton wrote:
> Dumb question: why not do this in userspace, presumably as part of the
> malloc() library?  malloc knows where all the memory is and should be
> able to kick off N threads to run around munmapping everything?

One of the places we saw this happen was when an app crashed and was
exit()'ing under duress without cleaning up nicely.  The time that it
takes to unmap a few TB of 4k pages is pretty excessive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
