Date: Thu, 22 May 2003 13:14:34 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.69-mm8
Message-Id: <20030522131434.710a0c7d.akpm@digeo.com>
In-Reply-To: <1053631843.2648.3248.camel@plars>
References: <20030522021652.6601ed2b.akpm@digeo.com>
	<1053629620.596.1.camel@teapot.felipe-alfaro.com>
	<1053631843.2648.3248.camel@plars>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: felipe_alfaro@linuxmail.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Larson <plars@linuxtestproject.org> wrote:
>
> 2.5.69-mm8 is bleeding for me. :)  See bugs #738 and #739.

#739 seems to be the b_committed_data race.  Alex is cooking up a fix for
that.  Sorry, I didn't realise it was that easy to trigger.

I'm fairly amazed about #738.  The asertion at fs/jbd/transaction.c:2023
(J_ASSERT_JH(jh, kernel_locked())) is bogus and should be removed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
