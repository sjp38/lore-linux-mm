Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 40AB86B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 18:14:00 -0400 (EDT)
Date: Sun, 16 Aug 2009 18:13:25 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: Discard support
Message-ID: <20090816221325.GF17958@mit.edu>
References: <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com> <20090814234539.GE27148@parisc-linux.org> <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com> <1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <20090816150530.2bae6d1f@lxorguk.ukuu.org.uk> <20090816083434.2ce69859@infradead.org> <1250437927.3856.119.camel@mulgrave.site> <adavdkn2ztb.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <adavdkn2ztb.fsf@cisco.com>
Sender: owner-linux-mm@kvack.org
To: Roland Dreier <rdreier@cisco.com>
Cc: James Bottomley <James.Bottomley@suse.de>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 16, 2009 at 02:50:40PM -0700, Roland Dreier wrote:
> 
>  > Well, yes and no ... a lot of SSDs don't actually implement NCQ, so the
>  > impact to them will be less ... although I think enterprise class SSDs
>  > do implement NCQ.
> 
> Really?  Which SSDs don't implement NCQ?

The Intel X25-M was the first SSD to implement NCQ.  The OCZ Core V2
advertised NCQ with a queue depth of 1, but even that was buggy, so
Linux has a black list for the that SSD:

      http://markmail.org/message/jvjpmcdqjwrmyl4w

As far as I know, all of the SSD's using the crappy JMicron JMF602
controllers don't support NCQ in any real way, which would includes
most of the reasonably priced SSD's up until first half of this year.
(The OCZ Summit SSD, which uses the Indilnx controller is an exception
to this statement, but it's more expensive that the JMF602 based
SSD's, although less expensive than the Intel SSD.)

JMicron is trying to seek redemption with their JMF612 controllers,
which were announced at the end of May of this year, and those
controllers do support NCQ, and are claimed to not to have the
disatrous small write latency problem of their '602 bretheren.  I'm
not aware of any products using the JMF612 yet, though.  (According to
reports the '612 controllers weren't going to hit mass production
until July, so hopefully later this fall we'll start seeing products
using the new JMicron controller.)

      	  				- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
