Date: Tue, 6 Mar 2007 10:26:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
Message-Id: <20070306102628.4c32fc65.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070305181826.GA21515@linux.intel.com>
References: <20070305181826.GA21515@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mgross@linux.intel.com
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Mar 2007 10:18:26 -0800
Mark Gross <mgross@linux.intel.com> wrote:

> It implements a convention on the 4 bytes of "Proximity Domain ID"
> within the SRAT memory affinity structure as defined in ACPI3.0a.  If
> bit 31 is set, then the memory range represented by that PXM is assumed
> to be power managed.  We are working on defining a "standard" for
> identifying such memory areas as power manageable and progress committee
> based.  
> 

This usage of bit 31 surprized me ;)
I think some vendor(sgi?) now using 4byte pxm...
no problem ? and othre OSs will handle this ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
