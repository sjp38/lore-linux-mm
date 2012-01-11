Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id A4A496B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 09:11:52 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <20237.39051.575883.450826@quad.stoffel.home>
Date: Wed, 11 Jan 2012 09:11:23 -0500
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
In-Reply-To: <CAHGf_=odfZxYS+PcMfeJ2ddFm76+-KbOLNrjGBtoEdExdQmL3Q@mail.gmail.com>
References: <20120109181023.7c81d0be@annuminas.surriel.com>
	<4F0B7D1F.7040802@gmail.com>
	<4F0BABE0.8080107@redhat.com>
	<CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com>
	<CAHGf_=odfZxYS+PcMfeJ2ddFm76+-KbOLNrjGBtoEdExdQmL3Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

>>>>> "KOSAKI" == KOSAKI Motohiro <kosaki.motohiro@gmail.com> writes:

>> Also, I doubt current swap_cluster default is best value on nowadays.
KOSAKI> I meant, current average hdd spec is,
KOSAKI>  - average seek time: 8.5ms
KOSAKI>  - sequential access performance: about 60MB/sec

KOSAKI> so, we can eat free lunch up to 7MB ~= 60(MB/sec) * 1000 / 8.5(ms).

What if the disk is busy doing other writeout or readin during this
time?  You can't assume you have the full disk bandwidth available,
esp when you hit a swap storm like this.  

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
