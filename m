Message-ID: <455B8F3A.6030503@mbligh.org>
Date: Wed, 15 Nov 2006 14:05:46 -0800
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost> <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christian Krafft <krafft@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 15 Nov 2006, Christian Krafft wrote:
> 
>> When booting a NUMA system with nodes that have no memory (eg by limiting memory),
>> bootmem_alloc_core tried to find pages in an uninitialized bootmem_map.
> 
> Why should we support nodes with no memory? If a node has no memory then 
> its processors and other resources need to be attached to the nearest node 
> with memory.
> 
> AFAICT The primary role of a node is to manage memory.

A node is an arbitrary container object containing one or more of:

CPUs
Memory
IO bus

It does not have to contain memory.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
