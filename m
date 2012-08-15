Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 910A16B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 05:05:35 -0400 (EDT)
Received: from relay2.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id AB653A3B06
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 11:05:33 +0200 (CEST)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: Strange VM stats in /proc/zoneinfo
Date: Wed, 15 Aug 2012 11:05:27 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201208151105.27411.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi folks,

while looking at my /proc/zoneinfo, I noticed that the counters are a bit 
strange:

Node 0, zone      DMA
  pages free     3945
        min      7
        low      8
        high     10
        scanned  0
        spanned  4080
        present  3905
    nr_free_pages 3945

OK, you'll probably argue that the rest is hidden in PCP differentials... BUT:

1. this machine has only 2 CPUs
2. stat_threshold = 4
3. vm_stat_diff[NR_FREE_PAGES] = 0 on both CPUs

Is this only me? Or do I misrepresent what these number actually tell?

TIA,
Petr Tesarik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
