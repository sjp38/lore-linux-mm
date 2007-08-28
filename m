Received: by fk-out-0910.google.com with SMTP id 18so2028827fkq
        for <linux-mm@kvack.org>; Tue, 28 Aug 2007 15:13:42 -0700 (PDT)
Message-ID: <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
Date: Tue, 28 Aug 2007 15:13:33 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH/RFC] Add node 'states' sysfs class attribute - V2
In-Reply-To: <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <20070827181405.57a3d8fe.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708271826180.10344@schroedinger.engr.sgi.com>
	 <20070827201822.2506b888.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272210210.9748@schroedinger.engr.sgi.com>
	 <20070827222912.8b364352.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
	 <20070827231214.99e3c33f.akpm@linux-foundation.org>
	 <1188309928.5079.37.camel@localhost>
	 <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On 8/28/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Tue, 28 Aug 2007, Lee Schermerhorn wrote:
>
> > I thought I'd give it a try, but thinking that /proc variables were
> > discouraged, where else but sysfs to put them.  A class attribute
> > to /sys/devices/system/node seemed like the appropriate place.
>
> Right. That is the right place.
>
> > I'm not wedded to this interface.  However, I realy don't think it's
> > worth doing as multiple files.
>
> I think one single file per nodemask makes sense. Otherwise files become
> difficult to parse. I just forgot....
>
> > its executed, in the grand scheme of things.  However, I must admit that
> > I've become addicted to the ease with which one can write one-off
> > scripts to query configuration/statistics, tune/modify behavior or
> > trigger actions via just cat'ing from and/or echo'ing to a /proc or /sys
> > file.
> >
> > So, where to go with this patch?  Drop it?  Leave it as is?  Move
> > it /proc so that it can be a single file?   Make it multiple files in
> > sysfs?  Putting it as politely as possible, the last is not my favorite
> > option, but if folks think this info is useful and that's the way to go,
> > so be it.  And what about mask vs list?  It's a 4 character change in
> > the code to go either way.
>
> I would suggest to do the one file thing in sysfs and use the function
> that already exists in the kernel to print the nice nodelists. Using the
> nice function is just calling another function since the code is already
> there.
>
> At some point we may even allow changing the nodemasks. One could imagine
> that we would add nodemasks that allow use of hugepages on certain nodes
> or the slab allocator to allocate on certain nodes.

Just to chime in here -- I've been on vacation for a bit recently -- I
fully support the one-value per file rule for sysfs. I think it makes
things a bit clearer. I like this attribute as well, and the idea of
expanding it down the road is easiest if we use one file per-nodemask.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
