Date: Tue, 17 Sep 2002 16:07:23 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: 2.5.35-mm1
Message-ID: <20020917160722.G39@toy.ucw.cz>
References: <3D858515.ED128C76@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3D858515.ED128C76@digeo.com>; from akpm@digeo.com on Mon, Sep 16, 2002 at 12:15:33AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lse-tech@lists.sourceforge.net" <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Hi!

> url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.35/2.5.35-mm1/
> 
> Significant rework of the new sleep/wakeup code - make it look totally
> different from the current APIs to avoid confusion, and to make it
> simpler to use.

Did you add any hooks to allow me to free memory for swsusp?
								Pavel
-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
