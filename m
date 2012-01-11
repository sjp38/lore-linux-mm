Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 77E706B006E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:17:03 -0500 (EST)
Date: Wed, 11 Jan 2012 13:17:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
In-Reply-To: <20237.39051.575883.450826@quad.stoffel.home>
Message-ID: <alpine.DEB.2.00.1201111305440.31239@router.home>
References: <20120109181023.7c81d0be@annuminas.surriel.com> <4F0B7D1F.7040802@gmail.com> <4F0BABE0.8080107@redhat.com> <CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com> <CAHGf_=odfZxYS+PcMfeJ2ddFm76+-KbOLNrjGBtoEdExdQmL3Q@mail.gmail.com>
 <20237.39051.575883.450826@quad.stoffel.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 11 Jan 2012, John Stoffel wrote:

> KOSAKI> so, we can eat free lunch up to 7MB ~= 60(MB/sec) * 1000 / 8.5(ms).
>
> What if the disk is busy doing other writeout or readin during this
> time?  You can't assume you have the full disk bandwidth available,
> esp when you hit a swap storm like this.

The assumptions by Kosaki are quite conservative.

What if one did not get a disk from the garbage heap but instead has a
state of the art storage cluster or simply an SSD (in particular relevant
now since HDs are in short supply given the situation in Asia)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
