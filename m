Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 017DB6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 18:50:18 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so1358362pbc.24
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:50:18 -0800 (PST)
Date: Wed, 27 Feb 2013 21:19:50 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [RFC PATCH v2 2/2] mm: tuning hardcoded reserved memory
Message-ID: <20130228021950.GA3829@localhost.localdomain>
References: <20130227210925.GB8429@localhost.localdomain>
 <20130228141441.7dbd19be.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130228141441.7dbd19be.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 28, 2013 at 02:14:41PM -0800, Andrew Morton wrote:
> On Wed, 27 Feb 2013 16:09:25 -0500
> Andrew Shewmaker <agshew@gmail.com> wrote:
> 
> > Add a rootuser_reserve_pages knob to allow admins of large memory 
> > systems running with overcommit disabled to change the hardcoded 
> > memory reserve to something other than 3%.
> > 
> > Signed-off-by: Andrew Shewmaker <agshew@gmail.com>
> > 
> > ---
> > 
> > Patch based off of mmotm git tree as of February 27th.
> > 
> > I set rootuser_reserve pages to be a default of 1000, and I suppose 
> > I should have initialzed similarly to the way min_free_kbytes is, 
> > scaling it with the size of the box. However, I wanted to get a 
> > simple version of this patch out for feedback to see if it has any 
> > chance of acceptance or if I need to take an entirely different 
> > approach.
> > 
> > Any feedback will be appreciated!
> 
> Seems reasonable.
> 
> Yes, we should scale the initial value according to the machine size in
> some fashion.
> 
> btw, both these patches had the same title.  Please avoid this.
> Documentation/SubmittingPatches section 15 has all the details.

Sorry about that. I'll resend correctly formatted patche submissions 
with a scaled initial value for rootuser_reserve_pages.

Thanks for the feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
