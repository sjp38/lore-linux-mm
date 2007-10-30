Date: Tue, 30 Oct 2007 18:26:01 -0400
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071030222601.GA1091@dmt>
References: <20071030191827.GB31038@dmt> <20071030210743.GA304@dmt> <20071030171909.3670f76f@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071030171909.3670f76f@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-mm@kvack.org, drepper@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 30, 2007 at 05:19:09PM -0400, Rik van Riel wrote:
> On Tue, 30 Oct 2007 17:07:43 -0400
> Marcelo Tosatti <marcelo@kvack.org> wrote:
> 
> > > Comments please...
> > 
> > changes:
> > - rearm timer (!)
> > - wake up one thread instead of all in swapout detection
> > - msecs_to_jiffies(1000) -> HZ
> 
> Would it be an idea to use round_jiffies() ?

Certainly, fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
