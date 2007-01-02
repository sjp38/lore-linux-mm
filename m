Date: Tue, 2 Jan 2007 08:37:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] optional ZONE_DMA
In-Reply-To: <20061229011151.GA2074@dmt>
Message-ID: <Pine.LNX.4.64.0701020835170.15611@schroedinger.engr.sgi.com>
References: <20061229011151.GA2074@dmt>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@suse.de>, Arjan van de Ven <arjan@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Dec 2006, Marcelo Tosatti wrote:

> Comments?

Great! Yes that is what I would like to see for x86. The general problem 
that Andi saw was that ZONE_DMA is not only used by device drivers (where 
we could add an explicit dependency) but also by subsystems for various 
nefarious purposes (f.e. SCSI). Maybe Andi can give us some more clarity 
on that issue?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
