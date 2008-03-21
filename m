Date: Fri, 21 Mar 2008 15:19:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [1/2] vmalloc: Show vmalloced areas via /proc/vmallocinfo
Message-Id: <20080321151935.6a330536.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0803201141250.10592@schroedinger.engr.sgi.com>
References: <20080318222701.788442216@sgi.com>
	<20080318222827.291587297@sgi.com>
	<20080319210436.191bb8fe@laptopd505.fenrus.org>
	<Pine.LNX.4.64.0803201141250.10592@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: arjan@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008 12:22:07 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 19 Mar 2008, Arjan van de Ven wrote:
> 
> > > +	proc_create("vmallocinfo",S_IWUSR|S_IRUGO, NULL,
> > why should non-root be able to read this? sounds like a security issue (info leak) to me...

What is the security concern here?  This objection is rather vague.

> Well I copied from the slabinfo logic (leaking info for slabs is okay?).
> 
> Lets restrict it to root then:
> 
> 
> 
> Subject: vmallocinfo: Only allow root to read /proc/vmallocinfo
> 
> Change permissions for /proc/vmallocinfo to only allow read
> for root.

That makes the feature somewhat less useful.  Let's think this through more
carefully - it is, after all, an unrevokable, unalterable addition to the
kernel ABI.

Arjan, what scenarios are you thinking about?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
