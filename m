Date: Wed, 6 Dec 2006 16:20:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] vmemmap on sparsemem v2 [1/5] generic vmemmap on
 sparsemem
In-Reply-To: <20061207092042.33533708.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0612061620350.30000@schroedinger.engr.sgi.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
 <20061205214902.b8454d67.kamezawa.hiroyu@jp.fujitsu.com>
 <20061206181317.GA10042@osiris.ibm.com> <Pine.LNX.4.64.0612061014210.26523@schroedinger.engr.sgi.com>
 <20061207092042.33533708.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: heiko.carstens@de.ibm.com, linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006, KAMEZAWA Hiroyuki wrote:

> Now, (for example ia64) sizeof(struct page)=56 and PAGES_PER_SECTION=65536,
> Then, sizeof(struct page) * PAGES_PER_SECTION is page-aligned.(16kbytes pages.)

Ahhh. Neat trick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
