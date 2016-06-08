Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E48046B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 05:23:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k192so1291501lfb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 02:23:59 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id l124si1063902wml.71.2016.06.08.02.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 02:23:58 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id r5so1386497wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 02:23:58 -0700 (PDT)
Subject: Re: [PATCH 0/9] [v2] System Calls for Memory Protection Keys
References: <20160607204712.594DE00A@viggo.jf.intel.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <6eaf31c0-0c94-6248-2ace-79e7c923a569@gmail.com>
Date: Wed, 8 Jun 2016 11:23:48 +0200
MIME-Version: 1.0
In-Reply-To: <20160607204712.594DE00A@viggo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: mtk.manpages@gmail.com, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, arnd@arndb.de

On 06/07/2016 10:47 PM, Dave Hansen wrote:
> Are there any concerns with merging these into the x86 tree so
> that they go upstream for 4.8?  

I believe we still don't have up-to-date man pages, right?
Best from my POV to send them out in parallel with the 
implementation.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
