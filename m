Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 8BFA16B0131
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 02:34:29 -0400 (EDT)
Received: by iec9 with SMTP id 9so5452702iec.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 23:34:28 -0700 (PDT)
Date: Wed, 12 Sep 2012 23:33:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and
 khugepaged_alloc_page
In-Reply-To: <alpine.LSU.2.00.1209122316200.7831@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1209122329320.7848@eggly.anvils>
References: <5028E12C.70101@linux.vnet.ibm.com> <5028E20C.3080607@linux.vnet.ibm.com> <alpine.LSU.2.00.1209111807030.21798@eggly.anvils> <50500360.5020700@linux.vnet.ibm.com> <alpine.LSU.2.00.1209122316200.7831@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 12 Sep 2012, Hugh Dickins wrote:
> > @@ -1825,6 +1825,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
> >  			return false;
> > 
> >  		*wait = false;
> > +		*hpage = NULL;
> >  		khugepaged_alloc_sleep();
> >  	} else if (*hpage) {
> >  		put_page(*hpage);
> 
> The unshown line just below this is
> 
> 		*hpage = NULL;
> 
> I do wish you would take the "*hpage = NULL;" out of if and else blocks
> and place it once below both.

Hold on, I'm being unreasonable: that's an "else if", and I've no good
reason to request you to set *hpage = NULL when it's already NULL.
It would be okay if you did, but there's no reason for me to prefer it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
