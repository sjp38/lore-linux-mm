Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAH06kYg023743
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 19:06:46 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAH080ie065076
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 17:08:03 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAH06htw006012
	for <linux-mm@kvack.org>; Wed, 16 Nov 2005 17:06:43 -0700
Date: Wed, 16 Nov 2005 16:06:26 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH 0/3] SPARSEMEM: pfn_to_nid implementation
Message-ID: <20051117000626.GD5628@w-mikek2.ibm.com>
References: <20051115221003.GA2160@w-mikek2.ibm.com> <exportbomb.1132181992@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <exportbomb.1132181992@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 16, 2005 at 10:59:53PM +0000, Andy Whitcroft wrote:
> Following this message are three patches:
> 
> kvaddr_to_nid-not-used-in-common-code: removes the unused interface
> kvaddr_to_nid().
> 
> pfn_to_pgdat-not-used-in-common-code: removes the unused interface
> pfn_to_pgdat().
> 
> sparse-provide-pfn_to_nid: provides pfn_to_nid() for SPARSEMEM.
> Note that this implmentation assumes the pfn has been validated
> prior to use.  The only intree user of this call does this.
> We perhaps need to make this part of the signature for this function.
> 
> Mike, how does this look to you?

I like the idea of getting rid of unused interfaces as well as getting
the node information from the page structs.  It works for me on powerpc.

-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
