Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 496BA6B0036
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:33:04 -0400 (EDT)
Date: Fri, 2 Aug 2013 12:32:59 +1000
From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 3/8] Add all memory via sysfs probe interface at once
Message-ID: <20130802023259.GC1680@concordia>
References: <51F01E06.6090800@linux.vnet.ibm.com>
 <51F01EFB.6070207@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F01EFB.6070207@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

On Wed, Jul 24, 2013 at 01:37:47PM -0500, Nathan Fontenot wrote:
> When doing memory hot add via the 'probe' interface in sysfs we do not
> need to loop through and add memory one section at a time. I think this
> was originally done for powerpc, but is not needed. This patch removes
> the loop and just calls add_memory for all of the memory to be added.

Looks like memory hot add is supported on ia64, x86, sh, powerpc and
s390. Have you tested on any?
 
cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
