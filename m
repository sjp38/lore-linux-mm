Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A354B6B0044
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 12:38:15 -0500 (EST)
Date: Tue, 15 Jan 2013 11:38:14 -0600
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Improving lock pages
Message-ID: <20130115173814.GA13329@gulag1.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: holt@sgi.com, linux-mm@kvack.org


Hello Mel,
    You helped some time ago with contention in lock_pages on very large boxes. 
You worked with Jack Steiner on this.  Currently I am tasked with improving this 
area even more.  So I am fishing for any more ideas that would be productive or 
worth trying. 

I have some numbers from a 512 machine.

Linux uvpsw1 3.0.51-0.7.9-default #1 SMP Thu Nov 29 22:12:17 UTC 2012 (f3be9d0) x86_64 x86_64 x86_64 GNU/Linux
      0.166850
      0.082339
      0.248428
      0.081197
      0.127635

Linux uvpsw1 3.8.0-rc1-medusa_ntz_clean-dirty #32 SMP Tue Jan 8 16:01:04 CST 2013 x86_64 x86_64 x86_64 GNU/Linux
      0.151778
      0.118343
      0.135750
      0.437019
      0.120536

Nathan Zimmer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
