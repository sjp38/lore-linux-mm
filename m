Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5792E6B0287
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 19:00:01 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fn5so8065459pab.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:00:01 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id z82si23129275pff.218.2016.10.25.16.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 16:00:00 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id s8so126903898pfj.2
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:00:00 -0700 (PDT)
Subject: Re: [PATCH v4 4/5] mm: make processing of movable_node arch-specific
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-5-git-send-email-arbab@linux.vnet.ibm.com>
 <235f2d20-cf84-08df-1fb4-08ee258fdc52@gmail.com>
 <dcfc8ace-e59e-6b4b-0f2f-4eff9f08f3c1@gmail.com>
 <20161025155507.37kv5akdlgo6m2be@arbab-laptop.austin.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <13f4f7fa-77b7-0924-f47c-5e55af8269d0@gmail.com>
Date: Wed, 26 Oct 2016 09:59:40 +1100
MIME-Version: 1.0
In-Reply-To: <20161025155507.37kv5akdlgo6m2be@arbab-laptop.austin.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org



On 26/10/16 02:55, Reza Arbab wrote:
> On Tue, Oct 25, 2016 at 11:15:40PM +1100, Balbir Singh wrote:
>> After the ack, I realized there were some more checks needed, IOW
>> questions for you :)
> 
> Hey! No takebacks!
> 

I still believe we need your changes, I was wondering if we've tested
it against normal memory nodes and checked if any memblock
allocations end up there. Michael showed me some memblock
allocations on node 1 of a two node machine with movable_node
I'll double check at my end. See my question below


> The short answer is that neither of these is a concern.
> 
> Longer; if you use "movable_node", x86 can identify these nodes at boot. They call memblock_mark_hotplug() while parsing the SRAT. Then, when the zones are initialized, those markings are used to determine ZONE_MOVABLE.
> 
> We have no analog of this SRAT information, so our movable nodes can only be created post boot, by hotplugging and explicitly onlining with online_movable.
>

Is this true for all of system memory as well or only for nodes
hotplugged later?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
