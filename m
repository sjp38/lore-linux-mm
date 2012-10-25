Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id B03CD6B0070
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 06:27:58 -0400 (EDT)
Date: Thu, 25 Oct 2012 11:20:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MMTests 0.06
Message-ID: <20121025102028.GB2558@suse.de>
References: <20121012145114.GZ29125@suse.de>
 <CALF0-+UBq8kgC-uUkuk_akoyBgvkytgn0v+2uBTDLZcFCPeHrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALF0-+UBq8kgC-uUkuk_akoyBgvkytgn0v+2uBTDLZcFCPeHrQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 24, 2012 at 05:14:31PM -0300, Ezequiel Garcia wrote:
> > The stats reporting still needs work because while some tests know how
> > to make a better estimate of mean by filtering outliers it is not being
> > handled consistently and the methodology needs work. I know filtering
> > statistics like this is a major flaw in the methodology but the decision
> > was made in this case in the interest of the benchmarks with unstable
> > results completing in a reasonable time.
> >
> 
> FWIW, I found a minor problem with sudo and yum incantation when trying this.
> 
> I'm attaching a patch.
> 

Thanks very much. I've picked it up and it'll be in MMTests 0.07.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
