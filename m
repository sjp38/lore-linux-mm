Date: Tue, 26 Jun 2001 17:02:55 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: all processes waiting in TASK_UNINTERRUPTIBLE state
Message-ID: <20010626170255.A554@athlon.random>
References: <OF29D2C834.F627AA03-ON85256A77.0050F2F6@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF29D2C834.F627AA03-ON85256A77.0050F2F6@pok.ibm.com>; from abali@us.ibm.com on Tue, Jun 26, 2001 at 10:47:12AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Tue, Jun 26, 2001 at 10:47:12AM -0400, Bulent Abali wrote:
> Andrea,
> I would like try your patch but so far I can trigger the bug only when
> running TUX 2.0-B6 which runs on 2.4.5-ac4.  /bulent
> 

to run tux you can apply those patches in `ls` order to 2.4.6pre5aa1:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.6pre5aa1/30_tux/*

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
