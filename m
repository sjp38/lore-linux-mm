Date: Wed, 5 Mar 2008 10:10:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] Cpuset hardwall flag:  Introduction
Message-Id: <20080305101015.cdff44f2.akpm@linux-foundation.org>
In-Reply-To: <20080305062318.3c7538c3.pj@sgi.com>
References: <20080305075237.608599000@menage.corp.google.com>
	<20080305062318.3c7538c3.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: menage@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Mar 2008 06:23:18 -0600 Paul Jackson <pj@sgi.com> wrote:

> Paul M wrote:
> > Currently the cpusets mem_exclusive flag is overloaded to mean both
> > "no-overlapping" and "no GFP_KERNEL allocations outside this cpuset".
> > 
> > These patches add a new mem_hardwall flag with just the allocation
> > restriction part of the mem_exclusive semantics, without breaking
> > backwards-compatibility for those who continue to use just
> > mem_exclusive.
> 
> ... too bad this nice comment wasn't included in PATCH 2/2, so that
> it would automatically make it into the record of history - the source
> control log message (as best I understand how Andrew's tools work,
> comments off in their own, codeless patch "PATCH 0/N" don't make
> it to the source control log, except when Andrew chooses to make a
> special effort.)

I make that special effort almost 100% of the time.  The changelog for the
first patch becomes:


<text from [0/n]>

This patch:

<text from [1/n]>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
