Date: Wed, 21 Jun 2000 17:49:11 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: Questions on pg_data_t structure
Message-Id: <20000621225539Z131176-21002+39@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ok, I've been trying to figure this stuff out over the past two weeks, and I
need help.

Here's what I think I know so far:

In a non-NUMA system, there is a single master pg_data_t structure called
contig_page_data.

contig_page_data contains two arrays, node_zonelists and node_zones.  There are
MAX_NR_ZONES (3) elements in node_zones, and there are 256 elements (of which
only the first 16 in non-CONFIG_HIGHMEM kernels are supposed to be used.)

Here's where I get confused:

node_zones is an array of zone_t structures.  node_zonelists is an array of
zonelist_t structures.  The zonelist_t structure also contains an array of
zone_t structures.  

My question is: what is the difference between the zone_t's in node_zones and
the zone_t's in each node_zonelists element?



--
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
