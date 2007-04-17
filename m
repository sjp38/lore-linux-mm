Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l3HHZW61031092
	for <linux-mm@kvack.org>; Tue, 17 Apr 2007 13:35:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HHcCCx166680
	for <linux-mm@kvack.org>; Tue, 17 Apr 2007 11:38:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HHc5Qj028745
	for <linux-mm@kvack.org>; Tue, 17 Apr 2007 11:38:05 -0600
Subject: Re: [PATCH] Show slab memory usage on OOM and SysRq-M (v2)
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <4624E8F4.2090200@sw.ru>
References: <4624E8F4.2090200@sw.ru>
Content-Type: text/plain
Date: Tue, 17 Apr 2007 10:37:53 -0700
Message-Id: <1176831473.12599.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@sw.ru>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eric Dumazet <dada1@cosmosbay.com>, Linux MM <linux-mm@kvack.org>, devel@openvz.org, Kirill Korotaev <dev@openvz.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-17 at 19:34 +0400, Pavel Emelianov wrote:
> +#define SHOW_TOP_SLABS 10 

Real minor nit on this one: SHOW_TOP_SLABS sounds like a bool.  "Should
I show the top slabs?"

This might be a bit more clear:

#define TOP_NR_SLABS_TO_SHOW 10 

or

#define NR_SLABS_TO_SHOW 10

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
