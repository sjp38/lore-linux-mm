Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k6BBEVmj105368
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 11:14:31 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6BBHOsZ145522
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 13:17:24 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6BBEUEg007486
	for <linux-mm@kvack.org>; Tue, 11 Jul 2006 13:14:30 +0200
Subject: Re: [patch] out of memory notifier - 2nd try.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <20060711041209.1c9cee49.akpm@osdl.org>
References: <20060711105148.GA28648@skybase>
	 <20060711041209.1c9cee49.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 11 Jul 2006 13:14:31 +0200
Message-Id: <1152616472.18034.0.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-07-11 at 04:12 -0700, Andrew Morton wrote:
> On Tue, 11 Jul 2006 12:51:48 +0200
> Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
> 
> > Hi folks,
> > I did not get any negative nor positive feedback on my proposed out of
> > memory notifier patch. I'm optimistic that this means that nobody has
> > anything against it ..
> 
> I have some negative feedback! ;)

Cool, thanks. I'll fix it.

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
