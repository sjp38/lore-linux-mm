Received: by nf-out-0910.google.com with SMTP id e27so498877nfd
        for <linux-mm@kvack.org>; Thu, 30 Aug 2007 09:44:37 -0700 (PDT)
Message-ID: <29495f1d0708300944o9aafdc5ob9dd30a687402ab@mail.gmail.com>
Date: Thu, 30 Aug 2007 09:44:36 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V4
In-Reply-To: <1188487157.5794.40.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <20070827222912.8b364352.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
	 <20070827231214.99e3c33f.akpm@linux-foundation.org>
	 <1188309928.5079.37.camel@localhost>
	 <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
	 <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
	 <1188398621.5121.13.camel@localhost>
	 <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
	 <1188487157.5794.40.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On 8/30/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> Try, try again.  Maybe closer this time.
>
> Question:  do we need/want to display the normal and high memory masks
> separately for systems with HIGHMEM?  If not, I'd suggest changing the
> print_nodes_state() function to take a nodemask_t* instead of a state
> enum and expose a single 'has_memory' attribute that we print using
> something like:

I feel like we should keep them separate. They are distinct in the
kernel for a reason, right? Do we perhaps actually want

has_normal_memory
has_highmem_memory
has_memory

That might be overkill, though -- and perhaps folks will argue you can
figure out the third by or'ing the results of the first two in a
script?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
