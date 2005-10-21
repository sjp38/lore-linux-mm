Message-ID: <43585EDE.3090704@jp.fujitsu.com>
Date: Fri, 21 Oct 2005 12:22:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020160638.58b4d08d.akpm@osdl.org> <20051020234621.GL5490@w-mikek2.ibm.com>
In-Reply-To: <20051020234621.GL5490@w-mikek2.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mike kravetz <kravetz@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

mike kravetz wrote:
> On Thu, Oct 20, 2005 at 04:06:38PM -0700, Andrew Morton wrote:

> Just to be clear, there are at least two distinct requirements for hotplug.
> One only wants to remove a quantity of memory (location unimportant).  The
> other wants to remove a specific section of memory (location specific).  I
> think the first is easier to address.
> 

The only difficulty to remove a quantity of memory is how to find
where is easy to be removed. If this is fixed, I think it is
easier to address.

My own target is NUMA-node-hotplug.
I want to make the possibility of hotplug *remove a specific section* be close to 100%.
Considering NUMA node hotplug,
if a process is memory location sensitve, it should be migrated before node is removed.
So, process migration by hand before system's memory hotplug looks attractive to me.

If we can implement memory migration before memory hotplug in good way,
I think it's good.

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
