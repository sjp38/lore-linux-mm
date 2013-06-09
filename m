Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 14E4C6B0031
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 08:02:11 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id eg20so4869159lab.5
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 05:02:09 -0700 (PDT)
Date: Sun, 9 Jun 2013 16:02:05 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH v11 20/25] drivers: convert shrinkers to new count/scan
 API
Message-ID: <20130609120204.GB5315@localhost.localdomain>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
 <1370550898-26711-21-git-send-email-glommer@openvz.org>
 <20130607141027.GH25649@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130607141027.GH25649@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Glauber Costa <glommer@openvz.org>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Kent Overstreet <koverstreet@google.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

On Fri, Jun 07, 2013 at 10:10:27AM -0400, Konrad Rzeszutek Wilk wrote:
> On Fri, Jun 07, 2013 at 12:34:53AM +0400, Glauber Costa wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Convert the driver shrinkers to the new API. Most changes are
> > compile tested only because I either don't have the hardware or it's
> > staging stuff.
> > 
> > FWIW, the md and android code is pretty good, but the rest of it
> > makes me want to claw my eyes out.  The amount of broken code I just
> > encountered is mind boggling.  I've added comments explaining what
> > is broken, but I fear that some of the code would be best dealt with
> > by being dragged behind the bike shed, burying in mud up to it's
> > neck and then run over repeatedly with a blunt lawn mower.
> 
> The rest being i915, ttm, bcache- etc ?
> 

Since all I have done for this patch in particular was to keep the
code going forward over the many iterations of the patchset, I will
leave the comments on this to my dear friend Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
