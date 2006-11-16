Received: by wr-out-0506.google.com with SMTP id i31so172029wra
        for <linux-mm@kvack.org>; Wed, 15 Nov 2006 16:44:59 -0800 (PST)
Message-ID: <9a8748490611151644m5420fd9claf8212f98a6ad4e2@mail.gmail.com>
Date: Thu, 16 Nov 2006 01:44:58 +0100
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [patch 2/2] enables booting a NUMA system where some nodes have no memory
In-Reply-To: <Pine.LNX.4.64.0611151440400.23201@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061115193049.3457b44c@localhost>
	 <20061115193437.25cdc371@localhost>
	 <Pine.LNX.4.64.0611151323330.22074@schroedinger.engr.sgi.com>
	 <455B8F3A.6030503@mbligh.org>
	 <Pine.LNX.4.64.0611151440400.23201@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@mbligh.org>, Christian Krafft <krafft@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 15/11/06, Christoph Lameter <clameter@sgi.com> wrote:
> On Wed, 15 Nov 2006, Martin Bligh wrote:
>
> > A node is an arbitrary container object containing one or more of:
> >
> > CPUs
> > Memory
> > IO bus
> >
> > It does not have to contain memory.
>
> I have never seen a node on Linux without memory. I have seen nodes
> without processors and without I/O but not without memory.This seems to be
> something new?
>
What about SMP Opteron boards that have RAM slots for each CPU?
With two (or more) CPU's and only memory slots populated for one of
them, wouldn't that count as multiple NUMA nodes but only one of them
with memory?
That would seem to be a pretty common thing that could happen.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
