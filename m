Date: Fri, 9 Mar 2007 00:15:12 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Message-ID: <20070308231512.GB1977@elf.ucw.cz>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200703041450.02178.rjw@sisk.pl> <1173315625.3546.32.camel@johannes.berg> <200703082305.43513.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200703082305.43513.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Johannes Berg <johannes@sipsolutions.net>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi!

> +		region = kzalloc(sizeof(struct nosave_region), GFP_ATOMIC);
> +		if (!region) {
> +			printk(KERN_WARNING "swsusp: Not enough memory "
> +				"to register a nosave region!\n");
> +			WARN_ON(1);
> +			return;
> +		}

That's a no-no. ATOMIC alocations can fail, and no, WARN_ON is not
enough. It is not a bug, they just fail.
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
