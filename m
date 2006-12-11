Date: Mon, 11 Dec 2006 09:23:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2
In-Reply-To: <20061210151931.GB28442@osiris.ibm.com>
Message-ID: <Pine.LNX.4.64.0612110922340.500@schroedinger.engr.sgi.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
 <457C0D86.70603@shadowen.org> <20061210151931.GB28442@osiris.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, 10 Dec 2006, Heiko Carstens wrote:

> Hmm.. this implementation still requires sparsemem. Maybe it would be
> possible to implement a generic vmem_map infrastructure that works with
> and without sparsemem?

What is the additional sparsemem overhead still around with this patchset?

I thought the sparsemem tables were replaced by the page tables?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
