Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LJUwnl006208
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 12:30:58 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LH8E8s14916426
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:08:14 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LH8EnB42434568
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:08:14 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft6Ba-00057c-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:08:14 -0700
Date: Wed, 21 Jun 2006 10:01:28 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [PATCH 06/14] Split NR_ANON_PAGES off from NR_FILE_MAPPED
In-Reply-To: <44996F34.1010805@google.com>
Message-ID: <Pine.LNX.4.64.0606211000230.19596@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
 <20060621154450.18741.47417.sendpatchset@schroedinger.engr.sgi.com>
 <44996F34.1010805@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606211008060.19596@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@google.com>
Cc: akpm@osdl.org, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2006, Martin J. Bligh wrote:

> Isn't this still the number of mapped anon pages, rather than the total
> number of anon pages?

All anonymous pages are mapped. If an anonymous page is unmapped then it 
is freed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
