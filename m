Date: Fri, 18 Nov 2005 11:56:57 -0800
From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
Message-ID: <20051118195657.GI7991@shell0.pdx.osdl.net>
References: <437E2C69.4000708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <437E2C69.4000708@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Matthew Dobson (colpatch@us.ibm.com) wrote:
> /proc/sys/vm/critical_pages: write the number of pages you want to reserve
> for the critical pool into this file

How do you size this pool?  Allocations are interrupt driven, so how to you
ensure you're allocating for the cluster network traffic you care about?

> /proc/sys/vm/in_emergency: write a non-zero value to tell the kernel that
> the system is in an emergency state and authorize the kernel to dip into
> the critical pool to satisfy critical allocations.

Seems odd to me.  Why make this another knob?  How did you run to set this
flag if you're in emergency and kswapd is going nuts?

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
