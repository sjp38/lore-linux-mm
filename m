From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16461.58880.459105.959740@laputa.namesys.com>
Date: Tue, 9 Mar 2004 18:42:56 +0300
Subject: Re: [RFC][PATCH 4/4] vm-mapped-x-active-lists
In-Reply-To: <200403091626.39479@WOLK>
References: <404D56D8.2000008@cyberone.com.au>
	<404D5784.9080004@cyberone.com.au>
	<200403091626.39479@WOLK>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>
Cc: linux-kernel@vger.kernel.org, Nick Piggin <piggin@cyberone.com.au>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marc-Christian Petersen writes:
 > On Tuesday 09 March 2004 06:35, Nick Piggin wrote:
 > 
 > Hi Nick,
 > 
 > seems the following patch is required ontop of your patches?
 > 
 > ciao, Marc
 > --- old/arch/i386/mm/hugetlbpage.c	2004-03-09 14:57:42.000000000 +0100
 > +++ new/arch/i386/mm/hugetlbpage.c	2004-03-09 15:36:15.000000000 +0100
 > @@ -411,8 +411,8 @@ static void update_and_free_page(struct 
 >  	htlbzone_pages--;
 >  	for (j = 0; j < (HPAGE_SIZE / PAGE_SIZE); j++) {
 >  		map->flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 > -				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
 > -				1 << PG_private | 1<< PG_writeback);
 > +				1 << PG_dirty | 1 << PG_active_mapped | 1 << PG_active_unapped |

PG_active_unapped?

 > +				1 << PG_reserved | 1 << PG_private | 1<< PG_writeback);
 >  		set_page_count(map, 0);
 >  		map++;
 >  	}

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
