Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 360176B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:54:46 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 29 May 2012 07:54:45 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 7374EC40003
	for <linux-mm@kvack.org>; Tue, 29 May 2012 07:54:39 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4TDsfK3038790
	for <linux-mm@kvack.org>; Tue, 29 May 2012 07:54:41 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4TDsdPR002980
	for <linux-mm@kvack.org>; Tue, 29 May 2012 07:54:39 -0600
Message-ID: <4FC4D51B.1000802@linux.vnet.ibm.com>
Date: Tue, 29 May 2012 08:54:35 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [GIT] (frontswap.v16-tag)
References: <20120518204211.GA18571@localhost.localdomain> <20120524202221.GA19856@phenom.dumpdata.com> <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
In-Reply-To: <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, JBeulich@novell.com, dan.magenheimer@oracle.com, linux-mm@kvack.org

Hi Linus,

On 05/27/2012 05:29 PM, Linus Torvalds wrote:

> On Thu, May 24, 2012 at 1:22 PM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
>>
>> I posted this while I was on vacation and just realized that I hadn't
>> put in the usual "GIT PULL" subject. Sorry about that - so sending
>> this in case this GIT PULL got lost in your 'not-git-pull-ignore-for-two-weeks'
>> folder. Cheers!
> 
> So that isn't actually the main reason I hadn't pulled, although being
> emailed a few days before the merge window opened did mean that it was
> fairly low down in my mailbox anyway..
> 
> No, the real reason is that for new features like this - features that
> I don't really see myself using personally and that I'm not all that
> personally excited about - I *really* want others to pipe up with
> "yes, we're using this, and yes, we want this to be merged".
> 
> It doesn't seem to be huge, which is great, but the deathly silence of
> nobody speaking up and saying "yes please", makes me go "ok, I won't
> pull if nobody speaks up for the feature".


We (IBM LTC) are interested in this feature being included.  We are
using it to enable main memory compression via the zcache driver in the
staging tree.  A lot of development is happening on the zcache and
zsmalloc drivers by Nitin, Minchan, and me.  But it is all (mostly) in
vain unless we can get frontswap.

I posted some numbers here...
https://lkml.org/lkml/2012/3/22/383

that demonstrate the benefit of zcache (another topic), but all that
isn't even an option without frontswap.

Frontswap is the swap-space complement to Cleancache which has already
been accepted.

Sorry for my late response, but we would be very interested in seeing
this feature in mainline.

Thanks,
Seth Jennings
IBM Linux Technology Center
POWER Virtualization

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
