Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k8C4FTJg006958
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 21:15:29 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k8C1ek8s39327035
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:40:46 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k8C1eknB56283876
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:40:46 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GMxGY-000201-00
	for <linux-mm@kvack.org>; Mon, 11 Sep 2006 18:40:46 -0700
Date: Mon, 11 Sep 2006 18:40:02 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
In-Reply-To: <450600C7.7090801@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0609111839140.7652@schroedinger.engr.sgi.com>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
 <450600C7.7090801@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0609111840410.7674@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@vger.kernel.org, Martin Bligh <mbligh@google.com>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2006, Nick Piggin wrote:

> I can't see from your patches, but what happens if someone asks
> for a GFP_DMA page or dma slab allocation when there is no ZONE_DMA?

The page/slab allocator will simply ignore the flag and return 
ZONE_NORMAL memory. See gfp_zone().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
