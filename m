Date: Tue, 10 Oct 2006 00:45:26 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.19-rc1-mm1
Message-Id: <20061010004526.c7088e79.akpm@osdl.org>
In-Reply-To: <1160464800.3000.264.camel@laptopd505.fenrus.org>
References: <20061010000928.9d2d519a.akpm@osdl.org>
	<1160464800.3000.264.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-kernel@vger.kernel.org, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2006 09:20:00 +0200
Arjan van de Ven <arjan@infradead.org> wrote:

> On Tue, 2006-10-10 at 00:09 -0700, Andrew Morton wrote:
> > +htlb-forget-rss-with-pt-sharing.patch

Which I didn't write.  cc's added.

> if it's ok to ignore RSS,

We'd prefer not to.  But what's the alternative?

> can we consider the shared pagetables for
> normal pages patch?

Has been repeatedly considered, but Hugh keeps finding bugs in it.

> It saves quite a bit of memory on even desktop
> workloads as well as avoiding several (soft) pagefaults.
> 
> So.. what does RSS actually mean? Can we ignore it somewhat for
> shared-readonly mappings ? 

We'd prefer to go the other way, and implement RLIMIT_RSS wouldn't we?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
