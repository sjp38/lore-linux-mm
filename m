Received: by el-out-1112.google.com with SMTP id z25so1142801ele.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2008 10:59:30 -0800 (PST)
Message-ID: <e2e108260802191059q17bceccdsb8e43dd043295a0b@mail.gmail.com>
Date: Tue, 19 Feb 2008 19:59:30 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: Synchronization of the procps tools with /proc/meminfo
In-Reply-To: <787b0d920802191053pea784fdycd3b5119cfb886a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802180755l1c80b13an89ed417c20132f08@mail.gmail.com>
	 <787b0d920802191053pea784fdycd3b5119cfb886a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <acahalan@cs.uml.edu>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Feb 19, 2008 7:53 PM, Albert Cahalan <acahalan@cs.uml.edu> wrote:
> On Feb 18, 2008 10:55 AM, Bart Van Assche <bart.vanassche@gmail.com> wrote:
>
> > This leads me to the question: if the layout of /proc/meminfo changes,
> > who communicates these changes to the procps maintainers ?
>
> Nobody ever informs me. :-(

That's very unfortunate.

But how should we proceed ? There is not only the SReclaimable field
that was added to /proc/meminfo, there is also the NFS_Unstable field.
I'm not sure whether that last one counts as reclaimable.

Note: Mel Gorman, who's also in CC, is on holiday but will jump in on
this discussion as soon as he's back from holiday.

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
