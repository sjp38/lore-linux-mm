Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0A7C26B0047
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 17:19:34 -0400 (EDT)
References: <1236891719.32630.14.camel@bahia>
	<20090312212124.GA25019@us.ibm.com>
	<604427e00903122129y37ad791aq5fe7ef2552415da9@mail.gmail.com>
	<20090313053458.GA28833@us.ibm.com>
	<alpine.LFD.2.00.0903131018390.3940@localhost.localdomain>
	<20090313193500.GA2285@x200.localdomain>
	<alpine.LFD.2.00.0903131401070.3940@localhost.localdomain>
	<1236981097.30142.251.camel@nimitz> <49BADAE5.8070900@cs.columbia.edu>
	<m1hc1xrlt5.fsf@fess.ebiederm.org> <20090314081207.GA16436@elte.hu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 19 Mar 2009 14:19:15 -0700
In-Reply-To: <20090314081207.GA16436@elte.hu> (Ingo Molnar's message of "Sat\, 14 Mar 2009 09\:12\:07 +0100")
Message-ID: <m1hc1p9pnw.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ do?
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:

> * Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> >> In the OpenVZ case, they've at least demonstrated that the 
>> >> filesystem can be moved largely with rsync.  Unlinked files 
>> >> need some in-kernel TLC (or /proc mangling) but it isn't 
>> >> *that* bad.
>> >
>> > And in the Zap we have successfully used a log-based 
>> > filesystem (specifically NILFS) to continuously snapshot the 
>> > file-system atomically with taking a checkpoint, so it can 
>> > easily branch off past checkpoints, including the file 
>> > system.
>> >
>> > And unlinked files can be (inefficiently) handled by saving 
>> > their full contents with the checkpoint image - it's not a 
>> > big toll on many apps (if you exclude Wine and UML...). At 
>> > least that's a start.
>> 
>> Oren we might want to do a proof of concept implementation 
>> like I did with network namespaces.  That is done in the 
>> community and goes far enough to show we don't have horribly 
>> nasty code.  The patches and individual changes don't need to 
>> be quite perfect but close enough that they can be considered 
>> for merging.
>> 
>> For the network namespace that seems to have made a big 
>> difference.
>> 
>> I'm afraid in our clean start we may have focused a little too 
>> much on merging something simple and not gone far enough on 
>> showing that things will work.
>> 
>> After I had that in the network namespace and we had a clear 
>> vision of the direction.  We started merging the individual 
>> patches and things went well.
>
> I'm curious: what is the actual end result other than good 
> looking code? In terms of tangible benefits to the everyday 
> Linux distro user. [This is not meant to be sarcastic, i'm
> truly curious.]

Of the network namespace?  Sorry I'm not certain what you are asking.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
