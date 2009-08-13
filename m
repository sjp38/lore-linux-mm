Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C3C36B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 01:05:10 -0400 (EDT)
From: Al Boldi <a1426z@gawab.com>
Subject: compcache as a pre-swap area (was: [PATCH] swap: send callback when swap slot is freed)
Date: Thu, 13 Aug 2009 08:05:36 +0300
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <4A837D5A.3070407@vflare.org>
In-Reply-To: <4A837D5A.3070407@vflare.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908130805.36787.a1426z@gawab.com>
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nitin Gupta wrote:
> BTW, last time compcache was not accepted due to lack of performance
> numbers. Now the project has lot more data for various cases:
> http://code.google.com/p/compcache/wiki/Performance
> Still need to collect data for worst-case behaviors and such...

I checked the link, and it looks like you are positioning compcache as a swap 
replacement.  If so, then repositioning it as a compressed pre-swap area 
working together with normal swap-space, if available, may yield a much more 
powerful system.


Thanks!

--
Al

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
