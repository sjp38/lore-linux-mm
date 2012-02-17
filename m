Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E052E6B00F8
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 10:27:59 -0500 (EST)
Received: by ghrr18 with SMTP id r18so2285850ghr.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 07:27:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTRrW4rAiC6UPGCFWChyuAjtbn7pkXRm3L2_SYdrRQCBZQ@mail.gmail.com>
References: <1329488869-7270-1-git-send-email-consul.kautuk@gmail.com>
	<1329491708.2293.277.camel@twins>
	<CAFPAmTRrW4rAiC6UPGCFWChyuAjtbn7pkXRm3L2_SYdrRQCBZQ@mail.gmail.com>
Date: Fri, 17 Feb 2012 10:27:59 -0500
Message-ID: <CAFPAmTRCoSqCVcN1ZnaWbKnadByEFkR17qH0wgmQQaoGv4K-Bw@mail.gmail.com>
Subject: Re: [PATCH 1/2] rmap: Staticize page_referenced_file and page_referenced_anon
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Okay, I sent v2 of this anyway with the correct description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
