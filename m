Received: from ife.ee.ethz.ch (ife-ife1.ee.ethz.ch [129.132.25.65])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA21100
	for <linux-mm@kvack.org>; Tue, 12 May 1998 06:43:05 -0400
Received: from eldrich.ee.ethz.ch (eldrich.ee.ethz.ch [129.132.24.203])
	by ife.ee.ethz.ch (8.8.5/8.8.5) with SMTP id MAA14011
	for <linux-mm@kvack.org>; Tue, 12 May 1998 12:42:43 +0200 (MET DST)
Message-ID: <355827A2.2844@ife.ee.ethz.ch>
Date: Tue, 12 May 1998 12:42:42 +0200
From: Thomas Sailer <sailer@ife.ee.ethz.ch>
MIME-Version: 1.0
Subject: bigphysarea in 2.1.x
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Is there somewhere a version of the bigphysarea patch for
recent 2.1.x kernels?

Or does anyone have a better idea how to allocate 1-4MByte
of nonpageable physically contiguous memory?

I need this to store the wavetable data in the SonicVibes
driver so that the chip can access it...

Tom
