From: Florian Schanda <ma1flfs@bath.ac.uk>
Reply-To: ma1flfs@bath.ac.uk
Subject: Re: 2.6.0-test5-mm4
Date: Mon, 22 Sep 2003 13:09:53 +0100
References: <20030922013548.6e5a5dcf.akpm@osdl.org>
In-Reply-To: <20030922013548.6e5a5dcf.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200309221309.53310.ma1flfs@bath.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 22 September 2003 09:35, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test5/2

Hi,

I need this patch to compile ide modules properly.

	Florian

--- old/drivers/block/ll_rw_blk.c       2003-09-22 12:59:39.000000000 +0100
+++ linux-2.6.0-test5/drivers/block/ll_rw_blk.c 2003-09-22 13:01:46.000000000 
+0100
@@ -2903,3 +2903,4 @@
 EXPORT_SYMBOL(blk_run_queues);
 
 EXPORT_SYMBOL(blk_rq_bio_prep);
+EXPORT_SYMBOL(blk_rq_prep_restart);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
