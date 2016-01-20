Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8160A6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:04:55 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so172141771wmf.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 02:04:55 -0800 (PST)
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com. [195.75.94.104])
        by mx.google.com with ESMTPS id b200si39590124wme.17.2016.01.20.02.04.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 02:04:54 -0800 (PST)
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 20 Jan 2016 10:04:53 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 87C4C2190019
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:04:39 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0KA4pVT7799168
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:04:51 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0KA4ocr019077
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 03:04:50 -0700
Date: Wed, 20 Jan 2016 11:04:48 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: Mlocked pages statistics shows bogus value.
Message-ID: <20160120100448.GF3395@osiris>
References: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
 <20160119122101.GA20260@node.shutemov.name>
 <201601192146.IFE86479.VMHLOFtQSOFFJO@I-love.SAKURA.ne.jp>
 <20160119130137.GA20984@node.shutemov.name>
 <201601192238.CEH73964.MOtFFLJVOOSHQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601192238.CEH73964.MOtFFLJVOOSHQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kirill@shutemov.name, walken@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 19, 2016 at 10:38:50PM +0900, Tetsuo Handa wrote:
> > > Don't we want to use "long" than "int" for all variables that count number
> > > of pages, for recently commit 6cdb18ad98a49f7e9b95d538a0614cde827404b8
> > > "mm/vmstat: fix overflow in mod_zone_page_state()" changed to use "long" ?
> > 
> > Potentially, yes. But here we count number of small pages in the compound
> > page. We're far from being able to allocate 8 terabyte pages ;)
> 
> That commit says "we have a 9TB system with only one node".
> You might encounter such machines in near future. ;-)

FWIW: in the above mentioned patch I wrote that I was just hoping that the
int -> long conversion could fix the boot issue with the >8TB machine.

It actually did fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
