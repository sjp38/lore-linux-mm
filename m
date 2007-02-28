Date: Wed, 28 Feb 2007 13:16:51 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Remove page flags for software suspend
In-Reply-To: <20070228210837.GA4760@ucw.cz>
Message-ID: <Pine.LNX.4.64.0702281315560.28432@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com>
 <200702161156.21496.rjw@sisk.pl> <20070228101403.GA8536@elf.ucw.cz>
 <Pine.LNX.4.64.0702280724540.16552@schroedinger.engr.sgi.com>
 <20070228210837.GA4760@ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Feb 2007, Pavel Machek wrote:

> Hmm, can't we just add another word to struct page?
> 
> Plus we really need PageNosave from boot on...

Well it would be great to get the story straight. First I was told that 
the bitmaps can be allocated later. Now we dont. The current patch should 
do what you want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
