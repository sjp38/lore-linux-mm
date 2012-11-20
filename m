Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 694A46B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 11:14:15 -0500 (EST)
Date: Tue, 20 Nov 2012 10:13:15 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: [PATCH] Revert "mm: remove __GFP_NO_KSWAPD"
Message-ID: <20121120161315.GA8338@wolff.to>
References: <5093A631.5020209@suse.cz>
 <509422C3.1000803@suse.cz>
 <509C84ED.8090605@linux.vnet.ibm.com>
 <509CB9D1.6060704@redhat.com>
 <20121109090635.GG8218@suse.de>
 <509F6C2A.9060502@redhat.com>
 <20121112113731.GS8218@suse.de>
 <CA+5PVA75XDJjo45YQ7+8chJp9OEhZxgPMBUpHmnq1ihYFfpOaw@mail.gmail.com>
 <20121116200616.GK8218@suse.de>
 <CA+5PVA7__=JcjLAhs5cpVK-WaZbF5bQhp5WojBJsdEt9SnG3cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CA+5PVA7__=JcjLAhs5cpVK-WaZbF5bQhp5WojBJsdEt9SnG3cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Zdenek Kabelac <zkabelac@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Thorsten Leemhuis <fedora@leemhuis.info>

On Tue, Nov 20, 2012 at 10:38:45 -0500,
   Josh Boyer <jwboyer@gmail.com> wrote:
>
>We've been tracking it in https://bugzilla.redhat.com/show_bug.cgi?id=866988
>and people say this revert patch doesn't seem to make the issue go away
>fully.  Thorsten has created another kernel with the other patch applied
>for testing.
>
>At least I think that is the latest status from the bug.  Hopefully the
>commenters will chime in.

I am seeing kswapd0 hogging a cpu right now. I have two rsyncs and an md sync 
running and a couple of large memory processes (java and firefox) idle.

I haven't been seeing this happen as often as previously. Before doing a 
yum update with an rsync was pretty good at triggering the problem. Now, 
not so much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
