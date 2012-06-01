Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 006006B00A3
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 16:51:41 -0400 (EDT)
Received: by wibhj6 with SMTP id hj6so848417wib.8
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 13:51:40 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <20120529140244.GA3558@phenom.dumpdata.com>
References: <20120518204211.GA18571@localhost.localdomain>
	<20120524202221.GA19856@phenom.dumpdata.com>
	<CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
	<20120529140244.GA3558@phenom.dumpdata.com>
Date: Fri, 1 Jun 2012 16:51:39 -0400
Message-ID: <CAPbh3rsLrvECi_GPo=zbsJ3Fmip6RE=FoRMdBk3hLKv5aD5=XQ@mail.gmail.com>
Subject: Re: [GIT] (frontswap.v16-tag)
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, sjenning@linux.vnet.ibm.com, JBeulich@novell.com, dan.magenheimer@oracle.com, linux-mm@kvack.org

>> No, the real reason is that for new features like this - features that
>> I don't really see myself using personally and that I'm not all that
>> personally excited about - I *really* want others to pipe up with
>> "yes, we're using this, and yes, we want this to be merged".
>>
>> It doesn't seem to be huge, which is great, but the deathly silence of
>> nobody speaking up and saying "yes please", makes me go "ok, I won't
>> pull if nobody speaks up for the feature".

Hey Linus.

A couple of folks here and in the past replies shared their thoughts,
but I don't think I said anything beyond dry technical details.

So I am really really excited about this.  I think this
"memory-that-is-not-your-old-memory" is an aspect of technology that
is going to evolve in interesting ways. The same way that SSDs kicked
the notion that "we have tons of milliseconds to do stuff before it
hits the platter" without costing a lot of money, the PCIe memory
cards (or whatever marketing name is used), PCIe inter-machine links,
or even on the embedded side of stuffing more in less, offer fantastic
opportunities. The frontswap provides a means to bridge a lot of these
technologies and share common concepts among them - there is the
compression for the embedded world, there is de-duplication for the
starving virtualization world, there is memory sharing across nodes,
and in my crystal ball  I see are those PCIe memory cards being used
too. It is really fun and invigorating and this patchset provides the
basic underpinnings for a lot of it.

So yes please pull!

git://git.kernel.org/pub/scm/linux/kernel/git/konrad/mm.git
stable/frontswap.v16-tag

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
