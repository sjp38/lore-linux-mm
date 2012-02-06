Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 8A33C6B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 08:15:11 -0500 (EST)
Received: by dadv6 with SMTP id v6so6051574dad.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 05:15:10 -0800 (PST)
Message-ID: <4F2FD25C.7070801@google.com>
Date: Mon, 06 Feb 2012 05:15:08 -0800
From: Paul Turner <pjt@google.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] [ATTEND] NUMA aware load-balancing
References: <20120131202836.GF31817@redhat.com>
In-Reply-To: <20120131202836.GF31817@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

I don't see it proposed as a topic yet (unless I missed it) but I spoke with
Peter briefly and I think this would be a good opportunity in particular to
discuss NUMA-aware load-balancing.  Currently, we only try to solve the 1-d
problem of optimizing for weight; but there's recently been interest from
several parties in improving this.  Issues involves proactively accounting for
the distribution of current allocations, determining when to initiate reactive
migration (or when not to move tasks!), and the associated grouping semantics.

Thanks,

- Paul

On 01/31/2012 12:28 PM, Andrea Arcangeli wrote:

> Hi everyone,
> 
> Just a reminder that if you'd like to attend the LSF/MM summit on
> April 1-2, the deadline to apply is February 5th at the end of this
> week. See below for more details.
> 
> If you did not already do so, please send [LSF/MM TOPIC] suggestions,
> or request to [ATTEND], to lsf-pc@lists.linux-foundation.org
> 
> Invitations will go out next week: so if you send a TOPIC or ATTEND
> mail now, you should expect confirmation next week - numbers
> permitting. We shall probably be unable to fulfil late requests to
> attend.
> 
> Thank you, and hope to see you soon :).
> Andrea, Hugh, Mel
> 
> ----- Forwarded message from Andrea Arcangeli <aarcange@redhat.com> -----
> 
> Date: Wed, 21 Dec 2011 15:43:48 +0100
> From: Andrea Arcangeli <aarcange@redhat.com>
> To: linux-mm@kvack.org
> Subject: [CFP] Linux Storage, Filesystem & Memory Management Summit 2012 (April 1-2)
> 
> The annual Linux Storage, Filesystem and Memory Management Summit for
> 2012 will be held on the 2 days preceding the Linux Foundation
> Collaboration Summit at Hotel Nikko in San Francisco, CA:
> 
> 	https://events.linuxfoundation.org/events/lsfmm-summit
> 	https://events.linuxfoundation.org/events/collaboration-summit/
> 
> We'd therefore like to issue a call for agenda proposals that are
> suitable for cross-track discussion as well as more technical subjects
> for discussion in the breakout sessions.
> 
> 1) Suggestions for agenda topics should be sent before February 5th
> 2012 to:
> 
> lsf-pc@lists.linux-foundation.org
> 
> and optionally cc the Linux list which would be most interested in it:
> 
> SCSI: linux-scsi@vger.kernel.org
> FS: linux-fsdevel@vger.kernel.org
> MM: linux-mm@kvack.org
> 
> Please remember to tag your subject with [LSF/MM TOPIC] to make it
> easier to track. Agenda topics and attendees will be selected by the
> programme committee, but the final agenda will be formed by consensus
> of the attendees on the day.
> 
> We'll try to cap attendance at around 25-30 per track to facilitate
> discussions although the final numbers will depend on the room sizes at
> the venue.
> 
> 2) Requests to attend should be sent to:
> 
> lsf-pc@lists.linux-foundation.org
> 
> please summarize what expertise you will bring to the meeting, and what
> you'd like to discuss.  please also tag your email with [ATTEND] so
> there's less chance of it getting lost in the large mail pile.
> 
> Presentations are allowed to guide discussion, but are strongly
> discouraged.  There will be no recording or audio bridge, however
> written minutes will be published as in previous years:
> 
> 2011:
> 
> http://lwn.net/Articles/436871/
> http://lwn.net/Articles/437066/
> 
> 2010:
> http://lwn.net/Articles/399148/
> http://lwn.net/Articles/399313/
> http://lwn.net/Articles/400589/
> 
> 2009:
> http://lwn.net/Articles/327601/
> http://lwn.net/Articles/327740/
> http://lwn.net/Articles/328347/
> 
> Prior years:
> http://www.usenix.org/events/lsf08/tech/lsf08sums.pdf
> http://www.usenix.org/publications/login/2007-06/openpdfs/lsf07sums.pdf
> 
> 3) If you have feedback on last year's meeting that we can use to
> improve this year's, please also send that to:
> 
> lsf-pc@lists.linux-foundation.org
> 
> Thank you on behalf of the Program Committee:
> 
> Storage
> 
> Jens Axboe
> James Bottomley
> Vivek Goyal
> Dan Williams
> 
> Filesystems
> 
> Trond Myklebust
> Chris Mason
> Christoph Hellwig
> Theodore Ts'o
> Mingming Cao
> Jan Kara
> Joel Becker
> 
> MM
> 
> Andrea Arcangeli
> Hugh Dickins
> Mel Gorman
> 
> ----- End forwarded message -----
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
