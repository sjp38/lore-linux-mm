Date: Sun, 24 Aug 2003 23:16:54 -0700
From: "Barry K. Nathan" <barryn@pobox.com>
Subject: pcnet32 oops patches (was Re: 2.6.0-test4-mm1)
Message-ID: <20030825061654.GB3562@ip68-4-255-84.oc.oc.cox.net>
References: <20030824171318.4acf1182.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030824171318.4acf1182.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, domen@coderock.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 24, 2003 at 05:13:18PM -0700, Andrew Morton wrote:
> +pcnet32-unregister_pci-fix.patch
> 
>  rmmod crash fix

Here's another (conflicting) patch by the same author:
http://bugme.osdl.org/attachment.cgi?id=684&action=view

There's an oops I'm having (bugzilla bug 976 -- basically, after
modprobing pcnet32 on a box without pcnet32 hardware, the next ethernet
driver to be modprobed blows up) which is not fixed by the patch in
test4-mm1, but which is fixed by attachment 684...

-Barry K. Nathan <barryn@pobox.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
