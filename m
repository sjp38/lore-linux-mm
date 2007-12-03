Subject: Re: [BUG 2.6.24-rc3-git6] SLUB's ksize() fails for size > 2048.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <200712021939.HHH18792.FLQSOOtFOFJVHM@I-love.SAKURA.ne.jp>
	<19f34abd0712020830y4825691atdfc9dac07ce4cb35@mail.gmail.com>
	<19f34abd0712020843m1dccfa3bu38388e1a53b05fc@mail.gmail.com>
In-Reply-To: <19f34abd0712020843m1dccfa3bu38388e1a53b05fc@mail.gmail.com>
Message-Id: <200712032033.DCF04184.LHJVOFtOFMFQSO@I-love.SAKURA.ne.jp>
Date: Mon, 3 Dec 2007 20:33:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: vegard.nossum@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello.

Vegard Nossum wrote:
> That didn't work. I guess that's what you get for no testing ;-) After
> some more investigations, it seems that this is the correct way to fix
> it (and tested!):
It worked in my environment too.

Please apply to 2.6.24-rc3-git6's tree.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
