Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC4B6B025E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 10:38:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so77710519pfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 07:38:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r1si12305809pax.317.2016.10.13.07.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 07:38:11 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9DEY5gn056016
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 10:38:10 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 262bwss9nr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 10:38:10 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 14 Oct 2016 00:38:07 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C0C402CE8059
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 01:38:05 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9DEc5ij62980328
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 01:38:05 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9DEc5pg025442
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 01:38:05 +1100
Date: Thu, 13 Oct 2016 20:08:03 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com> <57D1C914.9090403@intel.com> <57D63CB2.8070003@linux.vnet.ibm.com> <alpine.DEB.2.10.1609121106500.39030@chino.kir.corp.google.com> <57DCC605.10305@linux.vnet.ibm.com> <alpine.DEB.2.10.1609191752080.53329@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1609191752080.53329@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57FF9C4B.5040004@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On 09/20/2016 06:24 AM, David Rientjes wrote:
> On Sat, 17 Sep 2016, Anshuman Khandual wrote:
> 
>>> > > I'm questioning if this information can be inferred from information 
>>> > > already in /proc/zoneinfo and sysfs.  We know the no-fallback zonelist is 
>>> > > going to include the local node, and we know the other zonelists are 
>>> > > either node ordered or zone ordered (or do we need to extend 
>>> > > vm.numa_zonelist_order for default?).  I may have missed what new 
>>> > > knowledge this interface is imparting on us.
>> > 
>> > IIUC /proc/zoneinfo lists down zone internal state and statistics for
>> > all zones on the system at any given point of time. The no-fallback
>> > list contains the zones from the local node and fallback (which gets
>> > used more often than the no-fallback) list contains all zones either
>> > in node-ordered or zone-ordered manner. In most of the platforms the
>> > default being the node order but the sequence of present nodes in
>> > that order is determined by various factors like NUMA distance, load,
>> > presence of CPUs on the node etc. This order of nodes in the fallback
>> > list is the most important information derived out of this interface.
>> > 
> The point is that all of this can be inferred with information already 
> provided, so the additional interface seems unnecessary.  The only 
> extension I think that is needed is to determine if the order is node or 
> zone when vm.numa_zonelist_order == default and we shouldn't parse this 
> from dmesg.

Okay. Seems like the general view is that this interface is not necessary.
Hence wont be posting the debugfs version for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
