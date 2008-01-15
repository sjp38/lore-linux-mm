Date: Tue, 15 Jan 2008 18:03:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] mmaped copy too slow?
In-Reply-To: <1200387478.15103.21.camel@twins>
References: <20080115115318.1191.KOSAKI.MOTOHIRO@jp.fujitsu.com> <1200387478.15103.21.camel@twins>
Message-Id: <20080115180130.119A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Peter,

> > > While being able to deal with used-once mappings in page reclaim
> > > could be a good idea, this would require us to be able to determine
> > > the difference between a page that was accessed once since it was
> > > faulted in and a page that got accessed several times.
> > 
> > it makes sense that read ahead hit assume used-once mapping, may be.
> > I will try it.
> 
> I once had a patch that made read-ahead give feedback into page reclaim,
> but people didn't like it.

Could you please tell me your mail subject or URL?
I hope know why people didn't like.

thanks

- kosaki



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
