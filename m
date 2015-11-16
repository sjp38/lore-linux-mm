Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 71EAE6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 03:47:43 -0500 (EST)
Received: by wmww144 with SMTP id w144so99979144wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 00:47:43 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id wo7si44532285wjb.160.2015.11.16.00.47.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 00:47:42 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 16 Nov 2015 08:47:42 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 46D0717D8063
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:48:00 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tAG8ldVO41418768
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 08:47:39 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tAG7ldUf011247
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 00:47:40 -0700
Date: Mon, 16 Nov 2015 09:47:37 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
Message-ID: <20151116094737.270168cc@mschwide>
In-Reply-To: <201511131414.tADEE1co028795@d06av10.portsmouth.uk.ibm.com>
References: <201511111413.65wysS6A%fengguang.wu@intel.com>
	<20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org>
	<20151113125200.319a3101@mschwide>
	<201511131414.tADEE1co028795@d06av10.portsmouth.uk.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Krebbel1 <Andreas.Krebbel@de.ibm.com>
Cc: mschwid2@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, heicars2@linux.vnet.ibm.com, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Fri, 13 Nov 2015 16:13:46 +0100
"Andreas Krebbel1" <Andreas.Krebbel@de.ibm.com> wrote:

> this appears to be the result of aligning struct page to more than 8 bytes 
> and putting it onto the stack - wich is only 8 bytes aligned.  The 
> compiler has to perform runtime alignment to achieve that. It allocates 
> memory using *alloca* and does the math with the returned pointer. Our 
> dynamic stack allocation option basically only checks if there is an 
> alloca user.

I can confirm that this is caused by the struct page alignment, if I
force HAVE_ALIGNED_STRUCT_PAGE=n the warning vanishes.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
