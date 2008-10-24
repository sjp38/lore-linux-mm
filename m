From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
References: <87d4hugrwm.fsf@saeurebad.de>
	<20081021104357.GA12329@wotan.suse.de>
	<878wsigp2e.fsf_-_@saeurebad.de>
Date: Fri, 24 Oct 2008 02:21:32 +0200
In-Reply-To: <878wsigp2e.fsf_-_@saeurebad.de> (Johannes Weiner's message of
	"Tue, 21 Oct 2008 13:33:45 +0200")
Message-ID: <87zlkuj10z.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Finally got some half-way stable time numbers for this patch.

My approach was to generate background activity by dd'ing my hard-drive
to /dev/null and meanwhile copy a 1G file with memcpy() between two
mmaps and then the same file again with MADV_SEQUENTIAL mmaps.  The
numbers below are averages/standard deviations from 8 copy iterations.

I dropped the caches before each copy and waited for them to become
repopulated by the background dd.

The numbers in brackets are the std dev.

mmotm:
    normal  user: 1.775000s [0.053307] system: 9.620000s [0.135339] total: 98.875000s [0.613956]
   madvise  user: 2.552500s [0.041307] system: 9.442500s [0.075980] total: 73.937500s [0.734170]
mmotm+patch:
    normal  user: 1.850000s [0.013540] system: 9.760000s [0.047081] total: 99.250000s [0.569386]
   madvise  user: 2.547500s [0.014930] system: 8.865000s [0.055000] total: 71.897500s [0.144763]

Well, time-wise not sooo much of an improvement.  But given the
massively decreased LRU-rotation [ http://hannes.saeurebad.de/madvseq/ ]
I'm still looking forward to Kosaki-san's throughput measurements :)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
