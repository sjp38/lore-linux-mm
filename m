Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D49966B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:24:29 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ex14so166038666pac.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 22:24:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id cm7si18877917pad.48.2016.09.11.22.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 22:24:26 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8C5NC2j057845
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:24:25 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25ceawwnnr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 01:24:25 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 12 Sep 2016 15:24:22 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B220D3578057
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:24:19 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8C5OJjj6553924
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:24:19 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8C5OJ3u017520
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:24:19 +1000
Date: Mon, 12 Sep 2016 10:54:17 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm: Add sysfs interface to dump each node's zonelist
 information
References: <1473150666-3875-1-git-send-email-khandual@linux.vnet.ibm.com> <1473302818-23974-1-git-send-email-khandual@linux.vnet.ibm.com> <20160909133648.GL4844@dhcp22.suse.cz>
In-Reply-To: <20160909133648.GL4844@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D63C01.9090309@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Hansen <dave.hansen@intel.com>

On 09/09/2016 07:06 PM, Michal Hocko wrote:
> On Thu 08-09-16 08:16:58, Anshuman Khandual wrote:
>> > Each individual node in the system has a ZONELIST_FALLBACK zonelist
>> > and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
>> > order of zones during memory allocations. Sometimes it helps to dump
>> > these zonelists to see the priority order of various zones in them.
>> > 
>> > Particularly platforms which support memory hotplug into previously
>> > non existing zones (at boot), this interface helps in visualizing
>> > which all zonelists of the system at what priority level, the new
>> > hot added memory ends up in. POWER is such a platform where all the
>> > memory detected during boot time remains with ZONE_DMA for good but
>> > then hot plug process can actually get new memory into ZONE_MOVABLE.
>> > So having a way to get the snapshot of the zonelists on the system
>> > after memory or node hot[un]plug is desirable. This change adds one
>> > new sysfs interface (/sys/devices/system/memory/system_zone_details)
>> > which will fetch and dump this information.
> I am still not sure I understand why this is helpful and who is the
> consumer for this interface and how it will benefit from the
> information. Dave (who doesn't seem to be on the CC list re-added) had
> another objection that this breaks one-value-per-file rule for sysfs
> files.

It helps in understanding the relative priority of each memory zone of the
system during various allocation scenarios. Its particularly helpful after
hotplug/unplug of additional memory into previously non existing zone on
a node.

> 
> This all smells like a debugging feature to me and so it should go into
> debugfs.

Sure, will make it a debugfs interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
