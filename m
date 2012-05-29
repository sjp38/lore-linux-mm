Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D88F86B005A
	for <linux-mm@kvack.org>; Tue, 29 May 2012 10:23:21 -0400 (EDT)
Message-ID: <4FC4DBD2.1060807@redhat.com>
Date: Tue, 29 May 2012 10:23:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT] (frontswap.v16-tag)
References: <20120518204211.GA18571@localhost.localdomain> <20120524202221.GA19856@phenom.dumpdata.com> <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
In-Reply-To: <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, chris.mason@oracle.com, matthew@wil.cx, ngupta@vflare.org, hannes@cmpxchg.org, hughd@google.com, sjenning@linux.vnet.ibm.com, JBeulich@novell.com, dan.magenheimer@oracle.com, linux-mm@kvack.org

On 05/27/2012 06:29 PM, Linus Torvalds wrote:

> No, the real reason is that for new features like this - features that
> I don't really see myself using personally and that I'm not all that
> personally excited about - I *really* want others to pipe up with
> "yes, we're using this, and yes, we want this to be merged".

I do not like some of the implementation details in the code,
but I have no idea how to do it better.

The functionality, especially zram and frontswap, are very
desirable and would be good to have.

Pulling this code seems like the right thing to do.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
