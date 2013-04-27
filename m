Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id D39EF6B0032
	for <linux-mm@kvack.org>; Sat, 27 Apr 2013 04:34:06 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so595462pdi.7
        for <linux-mm@kvack.org>; Sat, 27 Apr 2013 01:34:06 -0700 (PDT)
Message-ID: <517B8D74.5050801@gmail.com>
Date: Sat, 27 Apr 2013 16:33:56 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: use direct_IO for writing swap pages
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi all,

Before commit commit 62c230bc1 (mm: add support for a filesystem to 
activate swap files and use direct_IO for writing swap pages), swap 
pages will write to page cache firstly and then writeback?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
