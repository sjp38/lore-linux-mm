From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16805.752.136395.85463@gargle.gargle.HOWL>
Date: Thu, 25 Nov 2004 00:53:52 +0300
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
In-Reply-To: <20041124163216.GB11432@logos.cnet>
References: <16800.47044.75874.56255@gargle.gargle.HOWL>
	<20041124163216.GB11432@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Linux Kernel Mailing List <Linux-Kernel@vger.kernel.org>, Andrew Morton <AKPM@Osdl.ORG>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti writes:
 > 
 > Hi Nikita,

Hello, Marcelo,

 > 

[...]

 > > +		if (pagezone != zone) {
 > > +			if (zone)
 > > +				local_unlock_irq(&zone->lru_lock);
 > 
 > You surely meant spin_{un}lock_irq and not local{un}lock_irq.

Oh, you are right. local_lock_* are functions to manipulate "local wait"
spin-lock variety that was introduced by some other
patch. batch-mark_page_accessed patch worked only because all references
to local_lock_* functions were removed by pvec-cleanup patch.

Another proof of the obvious fact that manually coded pagevec iteration
is evil. :)

 > 
 > Started the STP tests on 4way/8way boxes.

Great.

Nikita.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
