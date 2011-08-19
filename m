Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8102F6B016C
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 15:21:20 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p7JJLGlf030609
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 12:21:16 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz21.hot.corp.google.com with ESMTP id p7JJKlZv018433
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 12:21:15 -0700
Received: by pzk37 with SMTP id 37so9040374pzk.15
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 12:21:10 -0700 (PDT)
Date: Fri, 19 Aug 2011 12:21:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <201108190025.27444.vda.linux@googlemail.com>
Message-ID: <alpine.DEB.2.00.1108191219400.20477@chino.kir.corp.google.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <CAK1hOcM5u-zB7fUnR5QVJGBrEnLMhK9Q+EmWBknThga70UQaLw@mail.gmail.com> <CAG1a4rus+VVhhB3ayuDF2pCQDusLekGOAxf33+u_uzxC1yz1MA@mail.gmail.com> <201108190025.27444.vda.linux@googlemail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: Pavel Ivanov <paivanof@gmail.com>, Mahmood Naderan <nt_mahmood@yahoo.com>, Randy Dunlap <rdunlap@xenotime.net>, "\"linux-kernel@vger.kernel.org\"" <linux-kernel@vger.kernel.org>, "\"linux-mm@kvack.org\"" <linux-mm@kvack.org>

On Fri, 19 Aug 2011, Denys Vlasenko wrote:

> Exactly. Server has no means to know when the situation is
> bad enough to start killing. IIRC now the rule is simple:
> OOM killing starts only when allocations fail.
> 
> Perhaps it is possible to add "start OOM killing if less than N free
> pages are available", but this will be complex, and won't be good enough
> for some configs with many zones (thus, will require even more complications).
> 

Allocations start to fail, and oom killings then start to occur, only when 
the set of allowed zones fall below their minimum watermarks which usually 
includes several hundred kilobytes or several megabytes of free memory for 
lowmem situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
