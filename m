MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16102.15170.653446.711973@gargle.gargle.HOWL>
Date: Tue, 10 Jun 2003 16:10:42 -0400
From: "John Stoffel" <stoffel@lucent.com>
Subject: Re: 2.5.70-mm3 - Oops and hang
In-Reply-To: <20030610123732.562e7b22.akpm@digeo.com>
References: <16101.55819.768909.143767@gargle.gargle.HOWL>
	<20030610123732.562e7b22.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: John Stoffel <stoffel@lucent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zwane Mwaikambo <zwane@holomorphy.com>, Manfred Spraul <manfred@colorfullife.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Andrew> This appears to be a visitation from the Great Unsolved Bug of
Andrew> the 2.5 series.  Someone playing with a freed task_struct.

Ouch, not a good thing.

Andrew> Correct me if I'm wrong, but this has only ever been seen with
Andrew> CONFIG_PREEMPT=y?

I can't say, but I'm willing to apply patches to see if I can help
track it down.  I'm about to put -mm7 up on my machine and let that
run for a while.  

Is there anything special you want me to do to stress this out?

John
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
