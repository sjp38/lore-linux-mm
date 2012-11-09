Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7D5666B0044
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 11:14:46 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 9 Nov 2012 11:13:44 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5FE4C6E8062
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 11:13:25 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA9GDODA63701236
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 11:13:24 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA9GDNH3021098
	for <linux-mm@kvack.org>; Fri, 9 Nov 2012 11:13:24 -0500
Message-ID: <509D2B9B.4090305@linux.vnet.ibm.com>
Date: Fri, 09 Nov 2012 08:13:15 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/8][Sorted-buddy] mm: Linux VM Infrastructure to
 support Memory Power Management
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121108180257.GC8218@suse.de> <20121109051247.GA499@dirshya.in.ibm.com> <20121109090052.GF8218@suse.de> <509D185D.8070307@linux.vnet.ibm.com> <509D200F.2000908@linux.vnet.ibm.com>
In-Reply-To: <509D200F.2000908@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, akpm@linux-foundation.org, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/09/2012 07:23 AM, Srivatsa S. Bhat wrote:
> FWIW, kernbench is actually (and surprisingly) showing a slight performance
> *improvement* with this patchset, over vanilla 3.7-rc3, as I mentioned in
> my other email to Dave.
> 
> https://lkml.org/lkml/2012/11/7/428
> 
> I don't think I can dismiss it as an experimental error, because I am seeing
> those results consistently.. I'm trying to find out what's behind that.

The only numbers in that link are in the date. :)  Let's see the
numbers, please.

If you really have performance improvement to the memory allocator (or
something else) here, then surely it can be pared out of your patches
and merged quickly by itself.  Those kinds of optimizations are hard to
come by!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
