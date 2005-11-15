Date: Tue, 15 Nov 2005 11:20:42 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 03/05] mm rationalize __alloc_pages ALLOC_* flag names
Message-Id: <20051115112042.253ca3cf.pj@sgi.com>
In-Reply-To: <4379B0A7.3090803@yahoo.com.au>
References: <20051114040329.13951.39891.sendpatchset@jackhammer.engr.sgi.com>
	<20051114040353.13951.82602.sendpatchset@jackhammer.engr.sgi.com>
	<4379A399.1080407@yahoo.com.au>
	<20051115010303.6bc04222.akpm@osdl.org>
	<4379B0A7.3090803@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Simon.Derr@bull.net, clameter@sgi.com, rohit.seth@intel.com
List-ID: <linux-mm.kvack.org>

Nick suggested:
> ALLOC_DIP_NONE
> ALLOC_DIP_LESS
> ALLOC_DIP_MORE
> ALLOC_DIP_FULL

Sweet.  PATCH coming soon.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
