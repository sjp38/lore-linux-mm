Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DA87D6B0088
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 12:05:10 -0400 (EDT)
Date: Fri, 4 Sep 2009 09:05:03 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
 sc->isolate_pages() return value.
In-Reply-To: <alpine.DEB.2.00.0909032146130.10307@kernelhack.brc.ubc.ca>
Message-ID: <alpine.DEB.2.00.0909040856030.17650@kernelhack.brc.ubc.ca>
References: <1251935365-7044-1-git-send-email-macli@brc.ubc.ca> <20090903140602.e0169ffc.akpm@linux-foundation.org> <28c262360909031837j4e1a9214if6070d02cb4fde04@mail.gmail.com> <20090903190141.16ce4cf3.akpm@linux-foundation.org>
 <alpine.DEB.2.00.0909032146130.10307@kernelhack.brc.ubc.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 3 Sep 2009, Vincent Li wrote:

> On Thu, 3 Sep 2009, Andrew Morton wrote:
> 
> > On Fri, 4 Sep 2009 10:37:17 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > On Fri, Sep 4, 2009 at 6:06 AM, Andrew Morton<akpm@linux-foundation.org> wrote:
> > > > On Wed, __2 Sep 2009 16:49:25 -0700
> > > > Vincent Li <macli@brc.ubc.ca> wrote:
> > > >
> > > >> If we can't isolate pages from LRU list, we don't have to account page movement, either.
> > > >> Already, in commit 5343daceec, KOSAKI did it about shrink_inactive_list.
> > > >>
> > > >> This patch removes unnecessary overhead of page accounting
> > > >> and locking in shrink_active_list as follow-up work of commit 5343daceec.
> > > >>
> > > >> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> > > >> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > > >> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > >> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> > > >> Acked-by: Rik van Riel <riel@redhat.com>
> > > >>
> > > >> ---
> > > >> __mm/vmscan.c | __ __9 +++++++--
> > > >> __1 files changed, 7 insertions(+), 2 deletions(-)
> > > >>
> > > >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > >> index 460a6f7..2d1c846 100644
> > > >> --- a/mm/vmscan.c
> > > >> +++ b/mm/vmscan.c
> > > >> @@ -1319,9 +1319,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> > > >> __ __ __ if (scanning_global_lru(sc)) {
> > > >> __ __ __ __ __ __ __ zone->pages_scanned += pgscanned;
> > 
> > Someone's email client is replacing 0x09 with 0xa0, dammit.
> 
> I am using alpine 2.0, I got:
> 
>  [ Sending Preferences ]
>       [X]  Do Not Send Flowed Text                                               
>       [ ]  Downgrade Multipart to Text                                           
>       [X]  Enable 8bit ESMTP Negotiation    (default)
>       [ ]  Strip Whitespace Before Sending                                       
>  
> And Documentation/email-clients.txt have:
> 
> Config options:
> - quell-flowed-text is needed for recent versions
> - the "no-strip-whitespace-before-send" option is needed
> 
> Am I the one to blame? Should I uncheck the 'Do Not Send Flowed Text'? I 
> am sorry if it is my fault.

Ah, I quoted the pine Config options, the alpine config options from 
Documentation/email-clients.txt should be:

Config options:
In the "Sending Preferences" section:

- "Do Not Send Flowed Text" must be enabled
- "Strip Whitespace Before Sending" must be disabled

and my alpine did follow the recommendations as above showed.

I used 'git send-email' to send out the original patch.

Sorry again for the noise. 

Vincent Li
Biomedical Research Center
University of British Columbia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
