From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 05/21] hugetlb: new sysfs interface
Date: Mon, 23 Jun 2008 13:52:49 +1000
References: <20080604112939.789444496@amd.local0.net> <20080623024825.GE29413@wotan.suse.de> <20080622203126.955b9d02.akpm@linux-foundation.org>
In-Reply-To: <20080622203126.955b9d02.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806231352.50053.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, "Serge E. Hallyn" <serue@us.ibm.com>, kathys <kathys@au1.ibm.com>
List-ID: <linux-mm.kvack.org>

On Monday 23 June 2008 13:31, Andrew Morton wrote:
> On Mon, 23 Jun 2008 04:48:25 +0200 Nick Piggin <npiggin@suse.de> wrote:
> > I think the patch looks fine. Andrew, can you queue it?
>
> uh, yeah, appended.  The patch-related backlog appears to number
> 800-900 emails.  It's gonna be a fun week.

Good luck with that...


> btw, I'm rather concerned about -mm's MM changes from you and Rik - I
> saw a lot of emails go by but it's unclear that there was enough stuff
> there to get all of this stabilised.  Were you paying much attention?

As far as I could tell, the lockless pagecache stuff seems pretty
good after that first unlock_page fix. It also had an issue with
page migration that KOSAKI san fixed. There is an open bug report,
but it is against another patchset and doesn't appear to have been
a problem in -mm. It may be a reiser4 problem. I'll keep at it, but
I don't think it is cause for alarm.

The multiple hugepages set seems fine. Very little noise about it
which I guess is thanks in large part to good reviewing from others.

Rik/Lee's patchset seem to be getting rather a bit of noise, but I'm
sorry to say I haven't followed or reviewed it much yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
