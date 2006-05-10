Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k4ANiWnx007581
	for <linux-mm@kvack.org>; Wed, 10 May 2006 18:44:32 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k4B03Q7p28588938
	for <linux-mm@kvack.org>; Wed, 10 May 2006 17:03:26 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k4ANiVnB36218288
	for <linux-mm@kvack.org>; Wed, 10 May 2006 16:44:31 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FdyM3-0001zp-00
	for <linux-mm@kvack.org>; Wed, 10 May 2006 16:44:31 -0700
Date: Wed, 10 May 2006 16:42:01 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [RFC] Hugetlb demotion for x86
In-Reply-To: <1147287400.24029.81.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605101633140.7639@schroedinger.engr.sgi.com>
References: <1147287400.24029.81.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0605101644200.7676@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Seems that the code is not modifying x86 code but all code. 

An app should be getting an out of memory error and not a SIGBUS when 
running out of memory.

I thought we fixed the SIGBUS problems and were now reporting out of 
memory? If there still is an issue then we better fix out of memory 
handling. Provide a way for the app to trap OOM conditions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
