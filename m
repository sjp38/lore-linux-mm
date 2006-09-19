Date: Mon, 18 Sep 2006 17:14:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060918165808.c410d1d4.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609181711210.30365@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
 <20060918165808.c410d1d4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

i386 code for __inc_zone_page_state which does

void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
{
        __inc_zone_state(page_zone(page), item);
}
EXPORT_SYMBOL(__inc_zone_page_state);

objdump

0000078f <__inc_zone_page_state>:
 78f:   8b 00                   mov    (%eax),%eax
 791:   c1 e8 19                shr    $0x19,%eax
 794:   83 e0 01                and    $0x1,%eax
 797:   69 c0 80 04 00 00       imul   $0x480,%eax,%eax
 79d:   05 00 00 00 00          add    $0x0,%eax
 7a2:   e9 50 fe ff ff          jmp    5f7 <__inc_zone_state>
Disassembly of section .altinstr_replacement:

note no lookup anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
