Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAL5onho006620
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:50:49 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAL5oUmk080424
	for <linux-mm@kvack.org>; Sun, 20 Nov 2005 22:50:30 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAL5on7U023738
	for <linux-mm@kvack.org>; Sun, 20 Nov 2005 22:50:49 -0700
Message-ID: <43816038.9050700@us.ibm.com>
Date: Sun, 20 Nov 2005 21:50:48 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/8] Create Critical Page Pool
References: <437E2C69.4000708@us.ibm.com>	<437E2D23.10109@us.ibm.com> <20051118160855.1ea249c8.pj@sgi.com>
In-Reply-To: <20051118160855.1ea249c8.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Total nit:
> 
>  #define __GFP_HARDWALL   ((__force gfp_t)0x40000u) /* Enforce hardwall cpuset memory allocs */
> +#define __GFP_CRITICAL	((__force gfp_t)0x80000u) /* Critical allocation. MUST succeed! */
> 
> Looks like you used a space instead of a tab.

It's a tab on my side...  Maybe some whitespace munging by Thunderbird?
Will make sure it's definitely a tab on the next itteration.

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
