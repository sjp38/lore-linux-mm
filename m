From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Wed, 25 Jan 2006 16:48:58 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601241743.28889.raybry@mpdtxmail.amd.com>
 <07A9BE6C2CADACD27B259191@[10.1.1.4]>
In-Reply-To: <07A9BE6C2CADACD27B259191@[10.1.1.4]>
MIME-Version: 1.0
Message-ID: <200601251648.58670.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave,

Empirically, at least on Opteron, it looks like the first page of pte's is 
never shared, even if the alignment of the mapped region is correct (i. e. a 
2MB boundary for X86_64).    Is that what you expected?

(This is for a kernel built with just pte_sharing enabled, no higher levels.)

I would expect the first page of pte's not to be shared if the alignment is 
not correct, similarly for the last page if the mapped region doesn't 
entirely fill up the last page of pte's.

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
