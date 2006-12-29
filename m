Subject: Re: [PATCH 2/2] optional ZONE_DMA
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20061229011151.GA2074@dmt>
References: <20061229011151.GA2074@dmt>
Content-Type: text/plain
Date: Fri, 29 Dec 2006 09:37:51 +0100
Message-Id: <1167381471.20929.231.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@suse.de>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-12-28 at 23:11 -0200, Marcelo Tosatti wrote:
> The following patch turns ZONE_DMA into a configurable option on x86.
> 
> It also adds "select ZONE_DMA" entries in corresponding Kconfig files 
> for in-tree PCI drivers which have <32bit addressing limitation.

this select probably only works if all PCI architectures provide a
ZONE_DMA config option...


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
