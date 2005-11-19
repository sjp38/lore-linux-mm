Date: Fri, 18 Nov 2005 16:08:55 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH 1/8] Create Critical Page Pool
Message-Id: <20051118160855.1ea249c8.pj@sgi.com>
In-Reply-To: <437E2D23.10109@us.ibm.com>
References: <437E2C69.4000708@us.ibm.com>
	<437E2D23.10109@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Total nit:

 #define __GFP_HARDWALL   ((__force gfp_t)0x40000u) /* Enforce hardwall cpuset memory allocs */
+#define __GFP_CRITICAL	((__force gfp_t)0x80000u) /* Critical allocation. MUST succeed! */

Looks like you used a space instead of a tab.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
