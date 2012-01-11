Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 5242E6B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 03:02:16 -0500 (EST)
Received: by ghrr18 with SMTP id r18so214080ghr.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 00:02:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com>
References: <20120109181023.7c81d0be@annuminas.surriel.com>
 <4F0B7D1F.7040802@gmail.com> <4F0BABE0.8080107@redhat.com> <CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 11 Jan 2012 03:01:53 -0500
Message-ID: <CAHGf_=odfZxYS+PcMfeJ2ddFm76+-KbOLNrjGBtoEdExdQmL3Q@mail.gmail.com>
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

> Also, I doubt current swap_cluster default is best value on nowadays.

I meant, current average hdd spec is,
 - average seek time: 8.5ms
 - sequential access performance: about 60MB/sec

so, we can eat free lunch up to 7MB ~= 60(MB/sec) * 1000 / 8.5(ms).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
