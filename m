Subject: Re: 2.5.74-mm1
From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
In-Reply-To: <20030703023714.55d13934.akpm@osdl.org>
References: <20030703023714.55d13934.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1057248147.599.2.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Date: 03 Jul 2003 18:02:27 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-07-03 at 11:37, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.74/2.5.74-mm1/
> 
> . Included Con's CPU scheduler changes.  Feedback on the effectiveness of
>   this and the usual benchmarks would be interesting.
> 
>   Changes to the CPU scheduler tend to cause surprising and subtle problems
>   in areas where you least expect it, and these do take a long time to
>   materialise.  Alterations in there need to be made carefully and cautiously.
>   We shall see...

Currently testing all the new things...

>From what I've seen until date, the new scheduler patches are very, very
promising. I like them very much, but I still prefer Mike+Ingo combo
patch a little bit more for my laptop.

Will keep you informed if I see something strange ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
