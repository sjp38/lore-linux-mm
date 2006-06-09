From: Emanuel Hilgart <emanuel@et-hilgart.de>
Subject: zone->wait_table_bits contains a wrong value
Date: Fri, 9 Jun 2006 22:51:55 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606092251.55231.emanuel@et-hilgart.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am not sure if this is a bug.

The return value of wait_table_bits(unsigned long size) is too large. 
hash_long(val,zone->wait_table_bits) exceeds the maximum array index of 
zone->wait_table.

mm/page_alloc.c
/*
 * This is an integer logarithm so that shifts can be used later
 * to extract the more random high bits from the multiplicative
 * hash function before the remainder is taken.
 */
static inline unsigned long wait_table_bits(unsigned long size)
{
        return ffz(~size);
}


assumption:  
   wait_table_size := 0x10

conclusion:
  wait_table_bits(0x10) = 5
  hash_long(val,5) = [ 0 ; 0x1f ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
