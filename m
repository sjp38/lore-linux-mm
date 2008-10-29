Date: Wed, 29 Oct 2008 14:54:46 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: 2.6.28-rc2-mm1: possible circular locking
Message-ID: <20081029145446.081141b4@infradead.org>
In-Reply-To: <20081029135840.0a50e19c.akpm@linux-foundation.org>
References: <20081028233836.8b1ff9ae.akpm@linux-foundation.org>
	<200810292146.03967.m.kozlowski@tuxland.pl>
	<20081029135840.0a50e19c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mariusz Kozlowski <m.kozlowski@tuxland.pl>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008 13:58:40 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> We've been calling schedule_on_each_cpu() from within
> lru_add_drain_all() for ages.  What changed to cause all this
> to start happening?

what started to get these out of the weed is that copy_*_user() is now
annotated to (potentially) take the mmap sem (which it does if there's
a fault)... 
previously you had to actually fault to get the lock dependency noticed.

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit atty://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
