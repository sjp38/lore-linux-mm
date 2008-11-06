Subject: Re: [linux-pm] [PATCH] hibernation should work ok with memory
	hotplug
From: Nigel Cunningham <ncunningham@crca.org.au>
In-Reply-To: <Pine.LNX.4.44L0.0811060947250.2456-100000@iolanthe.rowland.org>
References: <Pine.LNX.4.44L0.0811060947250.2456-100000@iolanthe.rowland.org>
Content-Type: text/plain
Date: Fri, 07 Nov 2008 07:46:46 +1100
Message-Id: <1226004406.6876.5.camel@nigel-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Tolentino <matthew.e.tolentino@intel.com>, linux-pm@lists.osdl.org, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, pavel@suse.cz, Mel Gorman <mel@skynet.ie>, Andy Whitcroft <apw@shadowen.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi.

On Thu, 2008-11-06 at 09:48 -0500, Alan Stern wrote:
> On Thu, 6 Nov 2008, Nigel Cunningham wrote:
> 
> > Remember that when we hibernate (assuming we don't then suspend to ram),
> > the power is fully off. Resuming starts off like a fresh boot.
> 
> That simply is not true.  On ACPI systems, hibernation goes into the S4 
> state.  Power fully off is S5.

For the purposes of our discussion, it was a good enough description.
Nevertheless, you're right - if we do everything in a fully ACPI spec
compliant way, there will still be some power around. Of course we don't
always do that (can use S4 or S5).

Regards,

Nigel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
