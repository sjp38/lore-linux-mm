Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 59F156B0033
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 15:06:05 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Sat, 3 Aug 2013 05:02:58 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 08D8D3578051
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 05:06:01 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r72J5oDF14483576
	for <linux-mm@kvack.org>; Sat, 3 Aug 2013 05:05:50 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r72J60Hv007377
	for <linux-mm@kvack.org>; Sat, 3 Aug 2013 05:06:00 +1000
Message-ID: <51FC0315.1010601@linux.vnet.ibm.com>
Date: Fri, 02 Aug 2013 14:05:57 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] Mark powerpc memory resources as busy
References: <51F01E06.6090800@linux.vnet.ibm.com> <51F01EB2.9060802@linux.vnet.ibm.com> <20130802022827.GB1680@concordia>
In-Reply-To: <20130802022827.GB1680@concordia>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-mm <linux-mm@kvack.org>, isimatu.yasuaki@jp.fujitsu.com, linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 08/01/2013 09:28 PM, Michael Ellerman wrote:
> On Wed, Jul 24, 2013 at 01:36:34PM -0500, Nathan Fontenot wrote:
>> Memory I/O resources need to be marked as busy or else we cannot remove
>> them when doing memory hot remove.
> 
> I would have thought it was the opposite?

Me too.

As it turns out the code in kernel/resource.c checks to make sure the
IORESOURCE_BUSY flag is set when trying to release a resource.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
