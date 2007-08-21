Subject: Re: cpusets vs. mempolicy and how to get interleaving
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708201205450.28863@schroedinger.engr.sgi.com>
References: <46C63BDE.20602@google.com> <46C63D5D.3020107@google.com>
	 <alpine.DEB.0.99.0708190304510.7613@chino.kir.corp.google.com>
	 <46C8E604.8040101@google.com> <20070819193431.dce5d4cf.pj@sgi.com>
	 <46C92AF4.20607@google.com>
	 <Pine.LNX.4.64.0708201205450.28863@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 10:14:55 -0400
Message-Id: <1187705695.5066.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, Ethan Solomita <solo@google.com>, rientjes@google.com, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-20 at 12:07 -0700, Christoph Lameter wrote:
> On Sun, 19 Aug 2007, Ethan Solomita wrote:
> 
> > 	OK, then I'll proceed with a new MPOL. Do you believe that this will
> > be of general interest? i.e. worth placing in linux-mm?
> 
> Ummmm... Lets first get Lee onto this. AFAIK he already has an 
> implementation for such a thing.
> 
> Lee: Would you respond to these emails?
> 

Here's the post for cpuset-independent interleave [a.k.a. "contextual
interleave"].  

	http://marc.info/?l=linux-mm&m=118608528417158&w=4

I'm maintaining this with a half a dozen other mempolicy cleanups and
enhancements.  I'll try to post the entire series later this week.

Meanwhile, the patch linked above should apply to current mm tree with
little conflict.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
