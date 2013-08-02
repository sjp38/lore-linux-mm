Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id F3E1F6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 15:05:10 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Sat, 3 Aug 2013 16:00:06 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1774E3578051
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 05:05:05 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r72J4lEL9437612
	for <linux-mm@kvack.org>; Sat, 3 Aug 2013 05:04:54 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r72J4vY4006767
	for <linux-mm@kvack.org>; Sat, 3 Aug 2013 05:04:57 +1000
Message-ID: <51FC02D6.6050202@linux.vnet.ibm.com>
Date: Fri, 02 Aug 2013 14:04:54 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] register bootmem pages for powerpc when sparse vmemmap
 is not defined
References: <51F01E06.6090800@linux.vnet.ibm.com> <51F01E5F.80307@linux.vnet.ibm.com> <20130802022703.GA1680@concordia>
In-Reply-To: <20130802022703.GA1680@concordia>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-mm <linux-mm@kvack.org>, isimatu.yasuaki@jp.fujitsu.com, linuxppc-dev@lists.ozlabs.org, LKML <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 08/01/2013 09:27 PM, Michael Ellerman wrote:
> On Wed, Jul 24, 2013 at 01:35:11PM -0500, Nathan Fontenot wrote:
>> Previous commit 46723bfa540... introduced a new config option
>> HAVE_BOOTMEM_INFO_NODE that ended up breaking memory hot-remove for powerpc
>> when sparse vmemmap is not defined.
> 
> So that's a bug fix that should go into 3.10 stable?
> 

Yes, I believe this one as well as patch 2/8 should go into 3.10 stable.

I'll re-send with linux stable added.

-Nathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
