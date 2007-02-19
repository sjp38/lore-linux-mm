Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JJhnst015230
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 14:43:49 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JJhn8j499426
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:43:49 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JJhmHa001212
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:43:48 -0700
Subject: Re: [RFC][PATCH][1/4] RSS controller setup
From: Matthew Helsley <matthltc@us.ibm.com>
In-Reply-To: <45D98654.2020005@in.ibm.com>
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	 <20070219065026.3626.36882.sendpatchset@balbir-laptop>
	 <20070219005727.da2acdab.akpm@linux-foundation.org>
	 <6599ad830702190118r20b477d3q254c167c2fc2732@mail.gmail.com>
	 <45D98654.2020005@in.ibm.com>
Content-Type: text/plain
Date: Mon, 19 Feb 2007 11:43:46 -0800
Message-Id: <1171914227.29415.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-19 at 16:43 +0530, Balbir Singh wrote:
> Paul Menage wrote:
> > On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:

<snip>

> > Hmm, I don't appear to have documented this yet, but I think a good
> > naming scheme for container files is <subsystem>.<whatever> - i.e.
> > these should be memctlr.usage and memctlr.limit. The existing
> > grandfathered Cpusets names violate this, but I'm not sure there's a
> > lot we can do about that.
> > 
> 
> Why <subsystem>.<whatever>, dots are harder to parse using regular
> expressions and sound DOS'ish. I'd prefer "_" to separate the
> subsystem and whatever :-)

"_" is useful for names with "spaces". Names like mem_controller. "."
seems reasonable despite its regex nastyness. Alternatively there's
always ":".

<snip>

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
