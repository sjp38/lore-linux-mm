Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDB9F6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 16:29:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z36so6118628wrb.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 13:29:56 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id h6si2440529edd.444.2017.08.08.13.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 13:29:55 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id t201so16347437wmt.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 13:29:55 -0700 (PDT)
Date: Tue, 8 Aug 2017 23:29:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: A possible bug: Calling mutex_lock while holding spinlock
Message-ID: <20170808202953.tnb2p22hbpgc6aat@node.shutemov.name>
References: <2d442de2-c5d4-ecce-2345-4f8f34314247@amd.com>
 <20170803153902.71ceaa3b435083fc2e112631@linux-foundation.org>
 <20170804134928.l4klfcnqatni7vsc@black.fi.intel.com>
 <6027ba44-d3ca-9b0b-acdf-f2ec39f01929@amd.com>
 <fc466bf4-a658-f343-43f1-7e2f7ecb5d63@amd.com>
 <20170808170127.gjoijyxlm7z5nhmp@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808170127.gjoijyxlm7z5nhmp@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axie <axie@amd.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alex Deucher <alexander.deucher@amd.com>, "Writer, Tim" <Tim.Writer@amd.com>, linux-mm@kvack.org, "Xie, AlexBin" <AlexBin.Xie@amd.com>

On Tue, Aug 08, 2017 at 08:01:27PM +0300, Kirill A. Shutemov wrote:
> On Tue, Aug 08, 2017 at 12:51:15PM -0400, axie wrote:
> > Hi Kirill,
> > 
> > Here is the result from the user:"This patch does appear fix the issue."
> 
> Hm. Could you get logs from failure on the patched kernel?

Please ignore. I've misread what you wrote. %)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
