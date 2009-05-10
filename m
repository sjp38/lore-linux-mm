Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 35A8A6B00B9
	for <linux-mm@kvack.org>; Sun, 10 May 2009 10:59:00 -0400 (EDT)
Received: by gxk20 with SMTP id 20so5139721gxk.14
        for <linux-mm@kvack.org>; Sun, 10 May 2009 07:59:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4A06EA08.1030102@redhat.com>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	 <20090507134410.0618b308.akpm@linux-foundation.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <1241946446.6317.42.camel@laptop>
	 <2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com>
	 <20090510144533.167010a9@lxorguk.ukuu.org.uk>
	 <4A06EA08.1030102@redhat.com>
Date: Sun, 10 May 2009 23:59:54 +0900
Message-ID: <2f11576a0905100759n30fbc948wef34336774abfae1@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Hi

>> Secondly it moves the pressure from the storage volume holding the system
>> binaries and libraries to the swap device which already has to deal with
>> a lot of random (and thus expensive) I/O, as well as the users filestore
>> for mapped objects there - which may even be on a USB thumbdrive.
>
> Preserving the PROT_EXEC pages over streaming IO should not
> move much (if any) pressure from the file LRUs onto the
> swap-backed (anon) LRUs.

I don't think this is good example.
this issue is already solved by your patch. Thus this patch don't
improve streaming IO issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
