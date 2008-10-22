Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9M6dhVG027079
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 22 Oct 2008 15:39:43 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 013D32AC026
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 15:39:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CD99612C0A7
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 15:39:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EA8E1DB8041
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 15:39:42 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 28C501DB803F
	for <linux-mm@kvack.org>; Wed, 22 Oct 2008 15:39:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
In-Reply-To: <87ljwhfo4e.fsf@saeurebad.de>
References: <87r669fq2v.fsf@saeurebad.de> <87ljwhfo4e.fsf@saeurebad.de>
Message-Id: <20081022152911.1CD9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 22 Oct 2008 15:39:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> Is http://hannes.saeurebad.de/madvseq/ still true with this version?
> >
> > No, sorry, still running benchmarks on this version.  Coming up
> > soon...
> 
> Ok, reran the tests I used for the data on this website and updated it.
> Take a look.  I am quite overwhelmed by the results, hehe.
> 
> Kosaki-san, could you perhaps run the tests you did for the previous
> patch on this one, too?  I am not getting any stable results for
> throughput measuring...

Usually, any reclaim throughput mesurement isn't stable.
Then I used an average of five times mesurement.


Unfortunately, I can't understand I should mesure which patch combination
because you and Nick post many patches of this issue related yesterday.
Please let me know it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
