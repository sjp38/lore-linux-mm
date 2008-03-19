Received: by wr-out-0506.google.com with SMTP id c37so624128wra.26
        for <linux-mm@kvack.org>; Wed, 19 Mar 2008 08:20:42 -0700 (PDT)
Message-ID: <84144f020803190820o51b7af2bpf0e8f4cec62a2980@mail.gmail.com>
Date: Wed, 19 Mar 2008 17:20:41 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 7/9] slub: Adjust order boundaries and minimum objects per slab.
In-Reply-To: <1205888669.3215.587.camel@ymzhang>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080317230516.078358225@sgi.com>
	 <20080317230529.474353536@sgi.com> <47E00FEF.10604@cs.helsinki.fi>
	 <Pine.LNX.4.64.0803181159450.23790@schroedinger.engr.sgi.com>
	 <1205888669.3215.587.camel@ymzhang>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Yanmin,

On Wed, Mar 19, 2008 at 3:04 AM, Zhang, Yanmin
<yanmin_zhang@linux.intel.com> wrote:
>  In the other hand, memory is very cheap now. Usually users could install lots of memory
>  in server. So the competition among processors/processes are more severe.

Sure, but don't forget we have embedded users as well.

On Wed, Mar 19, 2008 at 3:04 AM, Zhang, Yanmin
<yanmin_zhang@linux.intel.com> wrote:
>  If both processor number and amount of memory are the input factor for min objects, I have
>  no objections but asking highlighting processer number. If not, I will like to choose processor
>  number.

I'm ok with your current scheme as it works nicely with low-end
machines as well. I was just curious to hear how you came up with
that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
