Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBHJHGph005472
	for <linux-mm@kvack.org>; Mon, 17 Dec 2007 14:17:16 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBHJHG3p433706
	for <linux-mm@kvack.org>; Mon, 17 Dec 2007 14:17:16 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBHJHGKm000654
	for <linux-mm@kvack.org>; Mon, 17 Dec 2007 14:17:16 -0500
Subject: Re: 1st version of azfs
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <OFE16CCD4C.0757B0AF-ONC12573B4.00642BAC-C12573B4.0066FFDD@de.ibm.com>
References: <OFE16CCD4C.0757B0AF-ONC12573B4.00642BAC-C12573B4.0066FFDD@de.ibm.com>
Content-Type: text/plain
Date: Mon, 17 Dec 2007 11:17:12 -0800
Message-Id: <1197919032.5385.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Maxim Shchetynin <maxim@de.ibm.com>
Cc: linuxppc-dev@ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, arnd@arndb.de
List-ID: <linux-mm.kvack.org>

On Mon, 2007-12-17 at 19:45 +0100, Maxim Shchetynin wrote:
> please, have a look at the following patch. This is a first version of a
> non-buffered filesystem to be used on "ioremapped" devices.
> Thank you in advance for your comments.

Dude, your patch is line-wrapped to hell.  Please don't use Notes to
post patches.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
