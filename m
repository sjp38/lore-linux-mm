Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id DCDA36B0032
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 13:45:57 -0400 (EDT)
Date: Mon, 15 Jul 2013 12:45:55 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
Message-ID: <20130715174551.GA58640@asylum.americas.sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com> <1373594635-131067-5-git-send-email-holt@sgi.com> <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Robin Holt <holt@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Jul 12, 2013 at 09:19:12PM -0700, Yinghai Lu wrote:
> On Thu, Jul 11, 2013 at 7:03 PM, Robin Holt <holt@sgi.com> wrote:
> > +
> >                 page = pfn_to_page(pfn);
> >                 __init_single_page(page, zone, nid, 1);
> > +
> > +               if (pfns > 1)
> > +                       SetPageUninitialized2Mib(page);
> > +
> > +               pfn += pfns;
> >         }
> >  }
> >
> > @@ -6196,6 +6302,7 @@ static const struct trace_print_flags pageflag_names[] = {
> >         {1UL << PG_owner_priv_1,        "owner_priv_1"  },
> >         {1UL << PG_arch_1,              "arch_1"        },
> >         {1UL << PG_reserved,            "reserved"      },
> > +       {1UL << PG_uninitialized2mib,   "Uninit_2MiB"   },
> 
> PG_uninitialized_2m ?
> 
> >         {1UL << PG_private,             "private"       },
> >         {1UL << PG_private_2,           "private_2"     },
> >         {1UL << PG_writeback,           "writeback"     },
> 
> Yinghai


I hadn't actually been very happy with having a PG_uninitialized2mib flag.
It implies if we want to jump to 1Gb pages we would need a second flag,
PG_uninitialized1gb, for that.  I was thinking of changing it to
PG_uninitialized and setting page->private to the correct order.
Thoughts?

Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
