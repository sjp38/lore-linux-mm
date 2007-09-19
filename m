Date: Wed, 19 Sep 2007 13:24:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 0/8] oom killer updates
In-Reply-To: <20070919124945.07cdbc50.pj@sgi.com>
Message-ID: <alpine.DEB.0.9999.0709191322530.26524@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <20070919124945.07cdbc50.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, andrea@suse.de, clameter@sgi.com, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Paul Jackson wrote:

> Earlier today, David wrote:
> > This patchset is an updated replacement of all patches posted by me to
> > linux-mm on September 18, 2007.
> 
> To what kernel version does this patch set apply?
> I don't see that mentioned in the patch set.
> 

It's against Linus' latest git.  I didn't apply it on top of the latest 
-mm because I'm not sure what parts of Andrea's patchset will be applied 
based on consensus.

Sorry for the confusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
