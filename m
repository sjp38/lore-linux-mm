MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16087.47491.603116.892709@gargle.gargle.HOWL>
Date: Fri, 30 May 2003 16:05:23 -0400
From: "John Stoffel" <stoffel@lucent.com>
Subject: Re: 2.5.70-mm2
In-Reply-To: <20030529042333.3dd62255.akpm@digeo.com>
References: <20030529012914.2c315dad.akpm@digeo.com>
	<20030529042333.3dd62255.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Andrew" == Andrew Morton <akpm@digeo.com> writes:

>> . A couple more locking mistakes in ext3 have been fixed.

Andrew> But not all of them.  The below is needed on SMP.

Any hint on when -mm3 will be out, and if it will include the RAID1
patches?  I haven't had time to play with -mm2, and all the stuff
floating by about problems has made me a bit hesitant to try it out.

John



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
