Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id C59DD6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 15:20:44 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so416106pbc.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2013 12:20:44 -0700 (PDT)
Date: Tue, 2 Apr 2013 12:20:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] THP: Use explicit memory barrier
In-Reply-To: <20130402003746.GA30444@blaptop>
Message-ID: <alpine.DEB.2.02.1304021215250.21661@chino.kir.corp.google.com>
References: <1364773535-26264-1-git-send-email-minchan@kernel.org> <alpine.DEB.2.02.1304011634530.21603@chino.kir.corp.google.com> <20130402003746.GA30444@blaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Tue, 2 Apr 2013, Minchan Kim wrote:

> Yes and Peter pointed out further step.
> Thanks for pointing out.
> Not that I know that Andrea alreay noticed it, I don't care about this
> patch.
> 

Andrea, do you have time to send

c08e0c9ee786 ("thp: add memory barrier to __do_huge_pmd_anonymous_page")
b08d75a595ec ("thp: document barrier() in wrprotect THP fault path")

from the master branch of aa.git to Andrew?  I would do it, but one isn't 
signed-off in your tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
