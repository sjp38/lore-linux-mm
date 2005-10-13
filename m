Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx3.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j9DJ7g7L003474
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 12:07:42 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j9DIKAAQ62754444
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 11:20:10 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j9DIH9sT95453020
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 11:17:09 -0700 (PDT)
Date: Thu, 13 Oct 2005 11:16:33 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Add page migration support via swap to the NUMA policy
 layer
In-Reply-To: <Pine.LNX.4.62.0510131114140.14810@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0510131115400.14810@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0510131114140.14810@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0510131117030.14847@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net
Cc: linux-mm@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

I forgot to say:

The patch requires the memory policy layering patch posted yesterday and 
the page eviction patch posted today to be applied to 2.6.14-rc4.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
