From: Domen Puncer <domen@coderock.org>
Subject: Re: pcnet32 oops patches (was Re: 2.6.0-test4-mm1)
Date: Mon, 25 Aug 2003 13:00:03 +0200
References: <20030824171318.4acf1182.akpm@osdl.org> <20030825061654.GB3562@ip68-4-255-84.oc.oc.cox.net>
In-Reply-To: <20030825061654.GB3562@ip68-4-255-84.oc.oc.cox.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200308251300.03421.domen@coderock.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Barry K. Nathan" <barryn@pobox.com>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 25 of August 2003 08:16, Barry K. Nathan wrote:
> On Sun, Aug 24, 2003 at 05:13:18PM -0700, Andrew Morton wrote:
> > +pcnet32-unregister_pci-fix.patch
> >
> >  rmmod crash fix
>
> Here's another (conflicting) patch by the same author:
> http://bugme.osdl.org/attachment.cgi?id=684&action=view
>
> There's an oops I'm having (bugzilla bug 976 -- basically, after
> modprobing pcnet32 on a box without pcnet32 hardware, the next ethernet
> driver to be modprobed blows up) which is not fixed by the patch in
> test4-mm1, but which is fixed by attachment 684...

That patch in test4-mm1... someone must have made my patch shorter...
and looks like he/she broke it. :-(

	Domen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
