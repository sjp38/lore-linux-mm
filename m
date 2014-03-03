Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 895DE6B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 14:15:32 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id x10so4063465pdj.23
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 11:15:32 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id po10si11614730pab.131.2014.03.03.11.15.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 11:15:31 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 4 Mar 2014 05:15:28 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 8FD1C2BB0045
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 06:15:24 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s23ItNaf11272632
	for <linux-mm@kvack.org>; Tue, 4 Mar 2014 05:55:24 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s23JFNag011699
	for <linux-mm@kvack.org>; Tue, 4 Mar 2014 06:15:23 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: Panic on ppc64 with numa_balancing and !sparsemem_vmemmap
In-Reply-To: <20140303172649.GU6732@suse.de>
References: <20140219180200.GA29257@linux.vnet.ibm.com> <20140303172649.GU6732@suse.de>
Date: Tue, 04 Mar 2014 00:45:19 +0530
Message-ID: <874n3fxfeg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: riel@redhat.com, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Mel Gorman <mgorman@suse.de> writes:

> On Wed, Feb 19, 2014 at 11:32:00PM +0530, Srikar Dronamraju wrote:
>> 
>> On a powerpc machine with CONFIG_NUMA_BALANCING=y and CONFIG_SPARSEMEM_VMEMMAP
>> not enabled,  kernel panics.
>> 
>
> This?

This one fixed that crash on ppc64

http://mid.gmane.org/1393578122-6500-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
