Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 085E06B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 11:36:22 -0400 (EDT)
Date: Wed, 24 Apr 2013 15:36:20 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
In-Reply-To: <20130424094732.GB31960@dhcp22.suse.cz>
Message-ID: <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com>
References: <alpine.DEB.2.02.1304161315290.30779@chino.kir.corp.google.com> <20130417094750.GB2672@localhost.localdomain> <20130417141909.GA24912@dhcp22.suse.cz> <20130418101541.GC2672@localhost.localdomain> <20130418175513.GA12581@dhcp22.suse.cz>
 <20130423131558.GH8001@dhcp22.suse.cz> <20130424044848.GI2672@localhost.localdomain> <20130424094732.GB31960@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 24 Apr 2013, Michal Hocko wrote:

> [CCing SL.B people and linux-mm list]
>
> Just for quick summary. The reporter sees OOM situations with almost
> whole memory filled with slab memory. This is a powerpc machine with 4G
> RAM.

Boot with "slub_debug" or enable slab debugging.

> /proc/slabinfo shows that almost whole slab occupied memory is on

Please enable debugging and look at where these objects were allocated.

> It is not clear who consumes that memory and the reporter claims this is
> vanilla 3.9-rc7 kernel without any third party modules loaded. The issue
> seems to be present only with CONFIG_SLUB.

cat /sys/kernel/slab/kmalloc-*/alloc_calls

will show where these objects are allocated.

A dump of the other fields in /sys/kernel/slab/kmalloc*/* would also be
useful.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
