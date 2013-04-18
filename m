Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 2010C6B0002
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 03:13:14 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Thu, 18 Apr 2013 08:10:34 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 90D6E1B0805F
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 08:13:04 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3I7CsJM41156774
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 07:12:54 GMT
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3I7D3Ya001826
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 01:13:03 -0600
Date: Thu, 18 Apr 2013 09:13:03 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG][s390x] mm: system crashed
Message-ID: <20130418071303.GB4203@osiris>
References: <156480624.266924.1365995933797.JavaMail.root@redhat.com>
 <2068164110.268217.1365996520440.JavaMail.root@redhat.com>
 <20130415055627.GB4207@osiris>
 <516B9B57.6050308@redhat.com>
 <20130416075047.GA4184@osiris>
 <1638103518.2400447.1366266465689.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1638103518.2400447.1366266465689.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 18, 2013 at 02:27:45AM -0400, Zhouping Liu wrote:
> Hello Heiko,
> > If you have some time, could you please repeat your test with the kernel
> > command line option " user_mode=home "?
> 
> I tested the system with the kernel parameter, but the issue still appeared,
> I just to say it takes longer time to reproduce the issue than the before.
> 
> > 
> > As far as I can tell there was only one s390 patch merged that was
> > mmap related: 486c0a0bc80d370471b21662bf03f04fbb37cdc6 "s390/mm: Fix crst
> > upgrade of mmap with MAP_FIXED".
> 
> also I tested the revert commit, unluckily, the same issue as the before.

Ok, thanks for verifying! I'll look into it; hopefully I can reproduce it
here as well.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
