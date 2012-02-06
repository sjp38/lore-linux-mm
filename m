Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 02C346B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 11:48:44 -0500 (EST)
Date: Mon, 6 Feb 2012 10:48:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] NUMA aware load-balancing
In-Reply-To: <4F2FD25C.7070801@google.com>
Message-ID: <alpine.DEB.2.00.1202061047450.2799@router.home>
References: <20120131202836.GF31817@redhat.com> <4F2FD25C.7070801@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Turner <pjt@google.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Mon, 6 Feb 2012, Paul Turner wrote:

> I don't see it proposed as a topic yet (unless I missed it) but I spoke with
> Peter briefly and I think this would be a good opportunity in particular to
> discuss NUMA-aware load-balancing.  Currently, we only try to solve the 1-d
> problem of optimizing for weight; but there's recently been interest from
> several parties in improving this.  Issues involves proactively accounting for
> the distribution of current allocations, determining when to initiate reactive
> migration (or when not to move tasks!), and the associated grouping semantics.

So this would mean having statistics that show how many pages are
allocated on each node and take that into consideration for load
balancing? Which is something that we felt to be desirable for a long
time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
