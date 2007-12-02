Date: Sun, 2 Dec 2007 17:16:13 +0100
From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG 2.6.24-rc3-git6] SLUB's ksize() fails for size > 2048.
Message-ID: <20071202161613.GM15974@stusta.de>
References: <200712021939.HHH18792.FLQSOOtFOFJVHM@I-love.SAKURA.ne.jp> <4752D59B.1020907@rtr.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4752D59B.1020907@rtr.ca>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Lord <lkml@rtr.ca>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Dec 02, 2007 at 10:56:11AM -0500, Mark Lord wrote:
> Tetsuo Handa wrote:
>...
>> kernel BUG at mm/slub.c:2562!
>...
> Is "p" NULL ?   Where'd your printk() output go to?

Check the source, that's not the BUG_ON(!object), it's the 
BUG_ON(!page).

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
