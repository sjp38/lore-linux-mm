Subject: Re: memory hotplug and mem=
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041007170138.GC15186@logos.cnet>
References: <20041001182221.GA3191@logos.cnet>
	 <4160F483.3000309@jp.fujitsu.com> <20041007155854.GC14614@logos.cnet>
	 <1097172146.22025.29.camel@localhost>  <20041007170138.GC15186@logos.cnet>
Content-Type: text/plain
Message-Id: <1097176228.24355.4.camel@localhost>
Mime-Version: 1.0
Date: Thu, 07 Oct 2004 12:10:28 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-10-07 at 10:01, Marcelo Tosatti wrote:
> mem=128M or mem=256M made it crash. Keep me posted.

So far, I've only tested it with highmem.  Your config will take some
tweaking because vmalloc space fills up all of lowmem if you don't use
it for ZONE_NORMAL at boot-time.  I'll work on fixing that.  But, you're
almost certainly going to be stuck adding the new memory to highmem, no
matter that it's really in the lower 1GB of physical memory.  Otherwise,
we're going to have to screw with vmalloc space.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
