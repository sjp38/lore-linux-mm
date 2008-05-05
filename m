Received: by rv-out-0708.google.com with SMTP id f25so981934rvb.26
        for <linux-mm@kvack.org>; Mon, 05 May 2008 11:04:43 -0700 (PDT)
Message-ID: <84144f020805051104v4118bd81g344622d5962314a4@mail.gmail.com>
Date: Mon, 5 May 2008 21:04:42 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB: Increasing partial pages
In-Reply-To: <Pine.LNX.4.64.0802161133000.25573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080116195949.GO18741@parisc-linux.org>
	 <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
	 <20080116214127.GA11559@parisc-linux.org>
	 <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
	 <20080116221618.GB11559@parisc-linux.org>
	 <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
	 <20080118191430.GD20490@parisc-linux.org>
	 <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
	 <20080216190727.GH7657@parisc-linux.org>
	 <Pine.LNX.4.64.0802161133000.25573@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2008 at 12:00:00PM -0800, Christoph Lameter wrote:
> > > Patches that I would recommend to test individually if you could do it
> > > (get the series via git pull
> > > git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git performance):

On Sat, 16 Feb 2008, Matthew Wilcox wrote:
>  > With these patches applied to 2.6.24-rc8, the perf team are seeing
>  > oopses while running the benchmark.  They're currently trying to narrow
>  > down which of the patches it is.  I'll get an oops for you to study when
>  > they've figured that out.

On Sat, Feb 16, 2008 at 10:34 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  There is also new code upstream now with significant changes that
>  affect performance. It may not be worthwhile to continue with 2.6.24-rc8
>  + patches.

Matthew, there are changes in 2.6.26-rc1 that might affect your
workload with SLUB:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=c124f5b54f879e5870befcc076addbd5d614663f

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=9b2cd506e5f2117f94c28a0040bf5da058105316

I would appreciate any updates where we currently stand with the
SLAB/SLUB performance regression on your TPC test. Thanks.

                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
