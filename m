Date: 2 Oct 2001 10:35:25 -0000
Message-ID: <20011002103525.12117.qmail@mailweb12.rediffmail.com>
MIME-Version: 1.0
From: "amey d inamdar" <iamey@rediffmail.com>
Reply-To: "amey d inamdar" <iamey@rediffmail.com>
Subject: How zone_balane_ratio is decided?
Content-type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: iamey@rediffmail.com
List-ID: <linux-mm.kvack.org>

Hello there,
   In a code of zone allocator free_area_init_core() minimum pages, low pages and high pages for any zone are decided using

mask = realpages/zone_balance_ratio
minpages=mask
low pages=2*mask 
high pages=3*mask

how zone balance ratio is decided for each zone? What is its significance? Please tell as soon as possible. I am unable to go further reading code. 
 Thanking you in anticipation

- Amey 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
