Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA4E6B0273
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 20:49:42 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id r13so13929217pag.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 17:49:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w9si19672676paz.315.2016.10.25.17.49.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 17:49:41 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q0mh1c123070
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 20:49:41 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ad0fr0ud-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 20:49:40 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 25 Oct 2016 18:49:39 -0600
Date: Tue, 25 Oct 2016 19:49:29 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 4/5] mm: make processing of movable_node arch-specific
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-5-git-send-email-arbab@linux.vnet.ibm.com>
 <235f2d20-cf84-08df-1fb4-08ee258fdc52@gmail.com>
 <dcfc8ace-e59e-6b4b-0f2f-4eff9f08f3c1@gmail.com>
 <20161025155507.37kv5akdlgo6m2be@arbab-laptop.austin.ibm.com>
 <112504e9-561d-e0da-7a40-73996c678b56@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <112504e9-561d-e0da-7a40-73996c678b56@gmail.com>
Message-Id: <20161026004929.h6v54dhehk4yvmwm@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 26, 2016 at 09:34:18AM +1100, Balbir Singh wrote:
>I still believe we need your changes, I was wondering if we've tested
>it against normal memory nodes and checked if any memblock
>allocations end up there. Michael showed me some memblock
>allocations on node 1 of a two node machine with movable_node

The movable_node option is x86-only. Both of those nodes contain normal 
memory, so allocations on both are allowed.

>> Longer; if you use "movable_node", x86 can identify these nodes at 
>> boot. They call memblock_mark_hotplug() while parsing the SRAT. Then, 
>> when the zones are initialized, those markings are used to determine 
>> ZONE_MOVABLE.
>>
>> We have no analog of this SRAT information, so our movable nodes can 
>> only be created post boot, by hotplugging and explicitly onlining 
>> with online_movable.
>
>Is this true for all of system memory as well or only for nodes
>hotplugged later?

As far as I know, power has nothing like the SRAT that tells us, at 
boot, which memory is hotpluggable. So there is nothing to wire the 
movable_node option up to.

Of course, any memory you hotplug afterwards is, by definition, 
hotpluggable. So we can still create movable nodes that way.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
