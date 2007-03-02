Date: Fri, 2 Mar 2007 14:50:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302145029.d4847577.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
	<45E7835A.8000908@in.ibm.com>
	<Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org>
	<20070301195943.8ceb221a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, balbir@in.ibm.com, mel@skynet.ie, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Mar 2007 21:11:58 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> The whole DRAM power story is a bedtime story for gullible children. Don't 
> fall for it. It's not realistic. The hardware support for it DOES NOT 
> EXIST today, and probably won't for several years. And the real fix is 
> elsewhere anyway (ie people will have to do a FBDIMM-2 interface, which 
> is against the whole point of FBDIMM in the first place, but that's what 
> you get when you ignore power in the first version!).
> 

At first, we have memory hot-add now. So I want to implement hot-removing 
hot-added memory, at least. (in this case, we don't have to write invasive
patches to memory-init-core.)

Our(Fujtisu's) product, ia64-NUMA server, has a feature to offline memory.
It supports dynamic reconfigraion of nodes, node-hoplug.

But there is no *shipped* firmware for hotplug yet. RHEL4 couldn't boot on
such hotplug-supported-firmware...so firmware-team were not in hurry.
It will be shipped after RHEL5 comes.
IMHO, a firmware which supports memory-hot-add are ready to support memory-hot-remove
if OS can handle it.

Note:
I heard embeded people often designs their own memory-power-off control on
embeded Linux. (but it never seems to be posted to the list.) But I don't know
they are interested in generic memory hotremove or not.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
