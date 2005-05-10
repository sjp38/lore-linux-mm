Message-Id: <200505101535.j4AFZtg23695@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Fw: [Bug 4520] New: /proc/*/maps fragments too quickly compared to
Date: Tue, 10 May 2005 08:35:54 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20050509142651.1d3ae91e.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andrew Morton' <akpm@osdl.org>, Wolfgang Wander <wwc@rentec.com>
Cc: mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote on Monday, May 09, 2005 2:27 PM
> Possibly for the 2.6.12 release the safest approach would be to just
> disable the free area cache while we think about it.

I hope people are not thinking permanently kill the free area cache
algorithm.  It is known to give a large percentage of performance gain
on specweb SSL benchmark.  I think it gives 4-5% gain from free area
cache algorithm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
