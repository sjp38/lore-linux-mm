Date: Tue, 9 Sep 2008 14:55:32 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Remove warning in compilation of ioremap
Message-ID: <20080909135532.GE8894@flint.arm.linux.org.uk>
References: <48C63E28.6060605@evidence.eu.com> <78442.11257.qm@web54403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78442.11257.qm@web54403.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Anders <dave123_aml@yahoo.com>
Cc: linux-arm-kernel@lists.arm.linux.org.uk, Claudio Scordino <claudio@evidence.eu.com>, linux-mm@kvack.org, Phil Blundell <philb@gnu.org>, "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 09, 2008 at 06:08:21AM -0700, David Anders wrote:
> Claudio,
> 
> i hope you have a better time getting this fixed than i have,
> i've been submitting patches as far back as 2.6.16:
> 
> http://lists.arm.linux.org.uk/lurker/message/20070906.135142.6c5e4d6f.en.html
> http://lists.arm.linux.org.uk/lurker/message/20070906.140649.79f143a0.en.html
> 
> 2.6.23 was when i gave up.

It's not like you were ignored, both of those messages contain replies
from Erik Mouw, both of which were positive.

Unfortunately, I didn't see it as a high priority so it got left a little
too long and I never got around to commenting about it (I thought it was
a complex way of fixing what was a trivial problem.)

Take a look at the difference between yours:

 http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=4563/1

Comapred with the one which has been merged:

 http://www.arm.linux.org.uk/developer/patches/viewpatch.php?id=5211/2

Sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
