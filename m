Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l1D9PSb9066706
	for <linux-mm@kvack.org>; Tue, 13 Feb 2007 09:25:28 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1D9PRbb991478
	for <linux-mm@kvack.org>; Tue, 13 Feb 2007 09:25:28 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1D9PRXY015081
	for <linux-mm@kvack.org>; Tue, 13 Feb 2007 09:25:27 GMT
Subject: Re: [patch 0/3] 2.6.20 fix for PageUptodate memorder problem (try
	3)
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20070213055229.GB18792@wotan.suse.de>
References: <20070210001844.21921.48605.sendpatchset@linux.site>
	 <1171147495.31563.5.camel@localhost> <20070213055229.GB18792@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 13 Feb 2007 10:25:33 +0100
Message-Id: <1171358733.3138.0.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-02-13 at 06:52 +0100, Nick Piggin wrote:
> Thanks for the confirmation.
> 
> I'll obviously have to resend a new patchset because I made a silly
> paper-bag bug with this one. May I say that the s390 specific part of
> the change is acked-by: you?

Yes.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
