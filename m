Subject: Re: [patch] Converting writeback linked lists to a tree based data
	structure
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080115080921.70E3810653@localhost>
References: <20080115080921.70E3810653@localhost>
Content-Type: text/plain
Date: Tue, 15 Jan 2008 09:46:14 +0100
Message-Id: <1200386774.15103.20.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Rubin <mrubin@google.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-15 at 00:09 -0800, Michael Rubin wrote:
> From: Michael Rubin <mrubin@google.com>
> 
> For those of you who have waited so long. This is the third submission
> of the first attempt at this patch. It is a trilogy.

Just a quick question, how does this interact/depend-uppon etc.. with
Fengguangs patches I still have in my mailbox? (Those from Dec 28th)





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
