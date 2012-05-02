Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3A1696B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 21:01:51 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so145754ghr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 18:01:50 -0700 (PDT)
Date: Tue, 1 May 2012 18:01:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] vmalloc: add warning in __vmalloc
In-Reply-To: <CAPa8GCD2m9R8YWY2FhO=LOMvCHhC6T=iFdn2YmpLxjO96_B4Ew@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205011800220.13575@chino.kir.corp.google.com>
References: <1335516144-3486-1-git-send-email-minchan@kernel.org> <alpine.DEB.2.00.1204270323000.11866@chino.kir.corp.google.com> <CAPa8GCBN6U_GRaG=GYFByNB4REcVA-yy+kKMMbrGaDKULUXW9w@mail.gmail.com> <alpine.DEB.2.00.1205011310180.7742@chino.kir.corp.google.com>
 <CAPa8GCD2m9R8YWY2FhO=LOMvCHhC6T=iFdn2YmpLxjO96_B4Ew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@gmail.com, Neil Brown <neilb@suse.de>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, Steven Whitehouse <swhiteho@redhat.com>, "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@newdream.net>

On Wed, 2 May 2012, Nick Piggin wrote:

> Because it needs to be an ongoing thing, which is caught as soon as the
> developer writes some code, rather than continually audited for and fixed
> up after the fact. There is not a good way to enforce this at compile time.
> 
> The existing callers do need to be fixed too, of course.
> 

I'm asking that existing callers be fixed up before such a warning is 
introduced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
