Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C70FF6B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 19:03:41 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so894576dak.34
        for <linux-mm@kvack.org>; Wed, 06 Feb 2013 16:03:41 -0800 (PST)
Date: Wed, 6 Feb 2013 16:03:38 -0800
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie
 to a config option
Message-ID: <20130207000338.GB18984@kroah.com>
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com>
 <20130206190924.GB32275@kroah.com>
 <761b5c6e-df13-49ff-b322-97a737def114@default>
 <20130206214316.GA21148@kroah.com>
 <abbc2f75-2982-470c-a3ca-675933d112c3@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <abbc2f75-2982-470c-a3ca-675933d112c3@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org

On Wed, Feb 06, 2013 at 02:42:11PM -0800, Dan Magenheimer wrote:
> > Yes, but these mm changes are in no one's trees, and I have no idea if
> > they ever will be merged.
> 
> OK, I can try pushing on the "egg" side for awhile :-(
> 
> > This patch looks to me that it is adding new functionality, and not
> > working to get it moved out of staging.
> 
> Not true... it is fixing broken functionality that was left latent
> for too long due to last summer's unpleasant disagreements.  And this
> functionality was a key reason why "zcache2" was created... because mm
> developers (e.g. Andrea) insisted that it must be present before compression
> functionality would be added into mm.  As evidence to support this,
> note that Seth's first zswap patchset includes similar functionality
> even though Seth argued vociferously last summer that the functionality
> wasn't needed before "old" zcache should be promoted.
> 
> > So, how about I try being mean again.  I will accept no more patches for
> > the zcache/zram/zsmalloc code, unless is it an obvious bugfix, or it is
> > to move it out of the drivers/staging/ tree.  You all have had many
> > years to get your act together, and it's getting really frustrating from
> > my end.
> 
> I do very much understand your frustration and you have every right
> to be mean.
> 
> But, since this really is technically patching up existing critical
> functionality that was known to be broken, I would be very grateful
> if you would reconsider applying this patch.  I agree there will be no
> (more) non-bugfix staging/zcache patches from me. I've proposed a topic [1]
> for LSF/MM in April to discuss all this... I totally agree it's time to
> promote in-kernel compression out of staging and into mm proper.
> But without this patch fixing required functionality, it will be
> harder to promote.
> 
> In other words.... pretty pleeeeze? I swear this is the last time.  :-]

That's what you said last time :)

So, how about this, please draw up a specific plan for how you are going
to get this code out of drivers/staging/  I want to see the steps
involved, who is going to be doing the work, and who you are going to
have to get to agree with your changes to make it happen.

After that, then I'll consider taking stuff like this, as it's "obvious"
that this is the way forward.  Right now I have no idea at all if this
is something new that you are adding, or if it's something that really
is helping to get the code merged.

Yeah, a plan, I know it goes against normal kernel development
procedures, but hey, we're in our early 20's now, it's about time we
started getting responsible.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
