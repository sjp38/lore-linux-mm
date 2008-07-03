Date: Thu, 3 Jul 2008 13:30:40 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080703173040.GB30506@mit.edu>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org> <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <486CC440.9030909@garzik.org> <Pine.LNX.4.64.0807031353030.11033@blonde.site> <486CCFED.7010308@garzik.org> <1215091999.10393.556.camel@pmac.infradead.org> <486CD654.4020605@garzik.org> <1215093175.10393.567.camel@pmac.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1215093175.10393.567.camel@pmac.infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jeff Garzik <jeff@garzik.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 03, 2008 at 02:52:55PM +0100, David Woodhouse wrote:
> 
> After feedback from a number of people, there is no individual Kconfig
> option for the various firmwares; there is only one which controls them
> all -- CONFIG_FIRMWARE_IN_KERNEL. The thing you're whining about isn't
> even part of the patch which needs review.
> 
> > Because of your stubborn refusal on this Kconfig defaults issue, WE 
> > ALREADY HAVE DRIVER-DOES-NOT-WORK BREAKAGE, JUST AS PREDICTED.
> 
> I strongly disagree that CONFIG_FIRMWARE_IN_KERNEL=y should be the
> default. But if I add this patch elsewhere in the kernel, will you quit
> your whining and actually review the patch you were asked to review? ...

I don't think it's whining.  If your patch introduces changes which
cause people .config to break by default after upgrading to a newer
kernel and doing "make oldconfig" --- then that's a problem with your
patch, and the missing hunk to enable CONFIG_FIRMWARE_IN_KERNEL=y is
critically important.

Linus has ruled this way in the past, when he's gotten screwed by this
sort of issue in the past, and he was justifiably annoyed.  We should
treat the users who are willing to test and provide feedback on the
latest kernel.org kernels with the same amount of regard.  And if
there are licensing religious fundamentalists who feel strongly about
the firmware issue, then fine, they can change the .config.  But the
default should be to avoid users from having broken kernels, and a
number of (quite clueful) users have already demonstrated that without
setting CONFIG_FIRMWARE_IN_KERNEL=y as the default, your patches cause
breakage.

Regards,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
