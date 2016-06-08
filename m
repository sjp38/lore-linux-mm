Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC366B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 13:35:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so22366311pfl.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 10:35:18 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id c185si2326028pfa.116.2016.06.08.10.35.17
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 10:35:17 -0700 (PDT)
Subject: Re: [PATCH 0/9] [v2] System Calls for Memory Protection Keys
References: <20160607204712.594DE00A@viggo.jf.intel.com>
 <6eaf31c0-0c94-6248-2ace-79e7c923a569@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <57585753.2080604@sr71.net>
Date: Wed, 8 Jun 2016 10:35:15 -0700
MIME-Version: 1.0
In-Reply-To: <6eaf31c0-0c94-6248-2ace-79e7c923a569@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, arnd@arndb.de

On 06/08/2016 02:23 AM, Michael Kerrisk (man-pages) wrote:
> On 06/07/2016 10:47 PM, Dave Hansen wrote:
>> > Are there any concerns with merging these into the x86 tree so
>> > that they go upstream for 4.8?  
> I believe we still don't have up-to-date man pages, right?
> Best from my POV to send them out in parallel with the 
> implementation.

I performed all the fixups and sent two dry-runs of the emails last week
instead of sending them out for real.  I will send them immediately.
Sorry for the delay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
