Date: Wed, 22 Oct 2008 00:41:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
Message-Id: <20081022004121.9c41c495.akpm@linux-foundation.org>
In-Reply-To: <87abcxksn1.fsf@saeurebad.de>
References: <87r669fq2v.fsf@saeurebad.de>
	<87ljwhfo4e.fsf@saeurebad.de>
	<20081022152911.1CD9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<87abcxksn1.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, npiggin@suse.de, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008 09:15:14 +0200 Johannes Weiner <hannes@saeurebad.de> wrote:

> Andrew's tree (not yet released) already has the first two changes, so
> if he releases a new mmotm in the meantime, you only need this patch on
> top of it.
> 

OK, there's one there now.

It gets multiple definitions of elfcorehdr_addr if you pick an
unfortunate config but I didn't bother fixing that because it'll
probably go away next time I merge everything.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
