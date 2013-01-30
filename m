Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2D65C6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:32:39 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 30 Jan 2013 10:32:37 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6FA6DC90049
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:32:34 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0UFWYS7273920
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:32:34 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0UFWVnr020359
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:32:32 -0500
Message-ID: <51093D03.8070006@linux.vnet.ibm.com>
Date: Wed, 30 Jan 2013 07:32:19 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
References: <201301142036.r0EKaYGN005907@como.maths.usyd.edu.au> <50F4A92F.2070204@linux.vnet.ibm.com> <20130130125151.GB19069@amd.pavel.ucw.cz>
In-Reply-To: <20130130125151.GB19069@amd.pavel.ucw.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: paul.szabo@sydney.edu.au, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/30/2013 04:51 AM, Pavel Machek wrote:
> Are you saying that HIGHMEM configuration with 4GB ram is not expected
> to work?

Not really.

The assertion was that 4GB with no PAE passed a forkbomb test (ooming)
while 4GB of RAM with PAE hung, thus _PAE_ is broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
