Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 509026B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 11:40:50 -0500 (EST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Subject: RE: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Date: Thu, 26 Jan 2012 11:40:47 -0500
Message-ID: <D3F292ADF945FB49B35E96C94C2061B915A64111@nsmail.netscout.com>
In-Reply-To: <20120125224614.GM30782@redhat.com>
References: <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost> <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca> <1327502034.2720.23.camel@menhir> <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com> <1327509623.2720.52.camel@menhir> <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com> <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com> <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com> <20120125200613.GH15866@shiny> <20120125224614.GM30782@redhat.com>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Chris Mason <chris.mason@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, "Darrick J.Wong" <djwong@us.ibm.com>

> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Sent: January 25, 2012 5:46 PM

....

> Way more important is to have feedback on the readahead hits and be
> sure when readahead is raised to the maximum the hit rate is near 100%
> and fallback to lower readaheads if we don't get that hit rate. But
> that's not a VM problem and it's a readahead issue only.
>=20

A quick google showed up - http://kerneltrap.org/node/6642=20

Interesting thread to follow. I haven't looked further as to what was
merged and what wasn't.

A quote from the patch - " It works by peeking into the file cache and
check if there are any history pages present or accessed."
Now I don't understand anything about this but I would think digging the
file-cache isn't needed(?). So, yes, a simple RA hit-rate feedback could
be fine.

And 'maybe' for adaptive RA just increase the RA-blocks by '1'(or some
N) over period of time. No more smartness. A simple 10 line function is
easy to debug/maintain. That is, a scaled-down version of
ramp-up/ramp-down. Don't go crazy by ramping-up/down after every RA(like
SCSI LLDD madness). Wait for some event to happen.

I can see where Andrew Morton's concerns could be(just my
interpretation). We may not want to end up like a protocol state machine
code: tcp slow-start, then increase , then congestion, then let's
back-off. hmmm, slow-start is a problem for my business logic, so let's
speed-up slow-start ;).


Chetan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
