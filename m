Message-Id: <200106251825.NAA02909@ccure.karaya.com>
Subject: Re: all processes waiting in TASK_UNINTERRUPTIBLE state 
In-Reply-To: Your message of "Mon, 25 Jun 2001 12:48:46 -0400."
             <OF831FC2D7.C211A862-ON85256A76.005AEC98@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Mon, 25 Jun 2001 13:25:22 -0500
From: Jeff Dike <jdike@karaya.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, James Stevenson <mistral@stev.org>, riel@conectiva.com.br
List-ID: <linux-mm.kvack.org>

abali@us.ibm.com said:
> Can you give more details?  Was there an aic7xxx scsi driver on the
> box? run_task_queue(&tq_disk) should eventually unlock those pages but
> they remain locked.  I am trying to narrow it down to fs/buffer code
> or the SCSI driver aic7xxx in my case.

Rik would be the one to tell you whether there was an aic7xxx driver on the 
physical box.  There obviously isn't one on UML, so if we're looking at the 
same bug, it's in the generic code.

				Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
