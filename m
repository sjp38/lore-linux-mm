Date: Thu, 6 Nov 2008 09:48:22 -0500 (EST)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory hotplug
In-Reply-To: <1225936818.6216.20.camel@nigel-laptop>
Message-ID: <Pine.LNX.4.44L0.0811060947250.2456-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 6 Nov 2008, Nigel Cunningham wrote:

> Remember that when we hibernate (assuming we don't then suspend to ram),
> the power is fully off. Resuming starts off like a fresh boot.

That simply is not true.  On ACPI systems, hibernation goes into the S4 
state.  Power fully off is S5.

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
