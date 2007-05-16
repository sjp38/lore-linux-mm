Received: by ik-out-1112.google.com with SMTP id c30so175605ika
        for <linux-mm@kvack.org>; Wed, 16 May 2007 10:27:12 -0700 (PDT)
Message-ID: <29495f1d0705161027v2b79ef5as394dbbef8d7eec0@mail.gmail.com>
Date: Wed, 16 May 2007 10:27:11 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1178738245.5047.67.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
	 <Pine.LNX.4.64.0705090956050.28244@schroedinger.engr.sgi.com>
	 <1178738245.5047.67.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Wed, 2007-05-09 at 09:57 -0700, Christoph Lameter wrote:
> > On Wed, 9 May 2007, Lee Schermerhorn wrote:
> >
> > > +                                   HUGETLB_PAGE_ORDER);
> > > +
> > > +           nid = next_node(nid, node_online_map);
> > > +           if (nid == MAX_NUMNODES)
> > > +                   nid = first_node(node_online_map);
> >
> > Maybe use nr_node_ids here? May save some scanning over online maps?
>
> Good idea.  I won't get to it until next week.  Maybe we'll have more
> comments by then.
>
> Anton:  anything to add?

Actually, I was going to ask? Why don't we just iterate over
node_populated_map? You've exported it and everything... Rather than
going over some other map and then checking to see if the node is
populated every time?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
