Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 080555F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 00:39:47 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 6so1578643yxn.26
        for <linux-mm@kvack.org>; Mon, 06 Apr 2009 21:40:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1239054936.8846.130.camel@nimitz>
References: <1239054936.8846.130.camel@nimitz>
Date: Tue, 7 Apr 2009 00:40:23 -0400
Message-ID: <787b0d920904062140n72b82c7mfc6ca78c291363f7@mail.gmail.com>
Subject: Re: [feedback] procps and new kernel fields
From: Albert Cahalan <acahalan@cs.uml.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: bart.vanassche@gmail.com, linux-mm <linux-mm@kvack.org>, procps-feedback@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Mon, Apr 6, 2009 at 5:55 PM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> Novell has integrated that patch into procps
...
> The most worrisome side-effect of this change to me is that we can no
> longer run vmstat or free on two machines and compare their output.

Right. Vendors never consier that. They then expect upstream
to accept and support their hack until the end of time.

> At the same time, we have machines that have dozens of GB of slab
> objects that are mostly reclaimable.  Yet, 'free' and 'vmstat' basically
> ignore slab.  Surely we need to find some way to report on those,
> especially since we can now break out {un,}reclaimable slab.
>
> We also have "new" memory use like unstable NFS pages.  How should we
> account for those?

How should I know? :-)

I've seen memstat fields go away before. This makes me
reluctant to bother with data that few people will need or
even understand. Why should I believe that these fields
are now securely part of the kernel ABI?

> I'd love to see an --extended output from things like vmstat. It could
> include wider output since fitting in 80 columns just isn't that
> important any more, and my 256GB machine's output really screws up the
> column alignment.

80 is still the default xterm width, the default console
width, and sometimes the only available width.

I certainly like the idea of allowing options for extra columns
and for wider columns.

The current code is too simplistic to handle such changes
without becoming an unreadable mess. It really needs to be
rewritten in a more serious style, much like ps.

> We could also add some information which is in
> addition to what we already provide in order to account for things like
> slab more precisely.

How do I even explain a slab? What about a slob or slub?
A few years from now, will this allocator even exist?

Remember that I need something for the man page, and most
of my audience knows almost nothing about programming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
