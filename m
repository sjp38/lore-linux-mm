Date: Wed, 15 Nov 2006 13:24:55 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have
 no memory
In-Reply-To: <20061115193437.25cdc371@localhost>
Message-ID: <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
References: <20061115193049.3457b44c@localhost> <20061115193437.25cdc371@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Krafft <krafft@de.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006, Christian Krafft wrote:

> When booting a NUMA system with nodes that have no memory (eg by limiting memory),
> bootmem_alloc_core tried to find pages in an uninitialized bootmem_map.

Why should we support nodes with no memory? If a node has no memory then 
its processors and other resources need to be attached to the nearest node 
with memory.

AFAICT The primary role of a node is to manage memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
