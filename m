Date: Tue, 2 Dec 2008 14:49:18 +0000
From: John Levon <levon@movementarian.org>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081202144918.GB24222@totally.trollied.org.uk>
References: <20081201083343.GC2529@wotan.suse.de> <20081201175113.GA16828@totally.trollied.org.uk> <20081201180455.GJ10790@wotan.suse.de> <20081201193818.GB16828@totally.trollied.org.uk> <20081202070608.GA28080@wotan.suse.de> <20081202130410.GA24222@totally.trollied.org.uk> <20081202134926.GA3235@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081202134926.GA3235@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Tue, Dec 02, 2008 at 02:49:26PM +0100, Nick Piggin wrote:

> > I can't believe I'm having to argue that you need to test your code. So
> > I think I'll stop.
> 
> Code was tested. It doesn't affect my normal oprofile usage (it's
> utterly within the noise, in case that wasn't obvious to you).

Then, heck, why didn't you say so?! I just went and read the whole
exchange and this is the first time you actually stated you tested the
impact of your patch on oprofile overhead.

It's in the noise, so it's fine.

regards
john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
