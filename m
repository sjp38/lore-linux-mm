Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 820986008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 12:04:25 -0400 (EDT)
Date: Wed, 19 May 2010 09:01:14 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unexpected splice "always copy" behavior observed
In-Reply-To: <E1OEldM-00063C-Ew@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LFD.2.00.1005190900050.23538@i5.linux-foundation.org>
References: <20100518153440.GB7748@Krystal> <1274197993.26328.755.camel@gandalf.stny.rr.com> <1274199039.26328.758.camel@gandalf.stny.rr.com> <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org> <20100519063116.GR2516@laptop>
 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org> <E1OElCI-0005v6-4D@pomaz-ex.szeredi.hu> <alpine.LFD.2.00.1005190831460.23538@i5.linux-foundation.org> <E1OEldM-00063C-Ew@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: npiggin@suse.de, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, peterz@infradead.org, fweisbec@gmail.com, tardyp@gmail.com, mingo@elte.hu, acme@redhat.com, tzanussi@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem@davemloft.net, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, tj@kernel.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>



On Wed, 19 May 2010, Miklos Szeredi wrote:
> 
> And predictability is good.  The thing I don't like about the above is
> that it makes it totally unpredictable which pages will get moved, if
> any.

Tough. 

Think of it this way: it is predictable. They get predictably moved when 
moving is cheap and easy. It's about _performance_. 

Do you know when TLB misses happen? They are unpredictable. Do you know 
when the OS sends IPI's around? Do you know when scheduling happens? 

No you don't. So stop whining.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
