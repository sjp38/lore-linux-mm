Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EC39C5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 09:02:38 -0400 (EDT)
Received: by bwz3 with SMTP id 3so3361738bwz.38
        for <linux-mm@kvack.org>; Tue, 07 Apr 2009 06:02:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <787b0d920904062140n72b82c7mfc6ca78c291363f7@mail.gmail.com>
References: <1239054936.8846.130.camel@nimitz>
	 <787b0d920904062140n72b82c7mfc6ca78c291363f7@mail.gmail.com>
Date: Tue, 7 Apr 2009 15:02:38 +0200
Message-ID: <e2e108260904070602p61b0be4fpc257f850b004c49f@mail.gmail.com>
Subject: Re: [feedback] procps and new kernel fields
From: Bart Van Assche <bart.vanassche@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Albert Cahalan <acahalan@cs.uml.edu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, procps-feedback@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Tue, Apr 7, 2009 at 6:40 AM, Albert Cahalan <acahalan@cs.uml.edu> wrote:
> On Mon, Apr 6, 2009 at 5:55 PM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>> Novell has integrated that patch into procps
>...
>> The most worrisome side-effect of this change to me is that we can no
>> longer run vmstat or free on two machines and compare their output.
>
> Right. Vendors never consier that. They then expect upstream
> to accept and support their hack until the end of time.

The patch that was integrated by this vendor in their procps package
was posted on a public mailing list more than a year ago. It would
have helped if someone would have commented earlier on that patch.

>> We could also add some information which is in
>> addition to what we already provide in order to account for things like
>> slab more precisely.
>
> How do I even explain a slab? What about a slob or slub?
> A few years from now, will this allocator even exist?
>
> Remember that I need something for the man page, and most
> of my audience knows almost nothing about programming.

It's not the difference between SLAB, SLOB and SLUB that matters here,
but the fact that some of the memory allocated by these kernel
allocators can be reclaimed. The procps tools currently count
reclaimable SLAB / SLOB / SLUB memory as used memory, which is
misleading. How can this be explained to someone who is not a
programmer ?

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
