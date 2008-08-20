Subject: Re: [PATCH 6/6] Mlock: make mlock error return Posixly Correct
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <84144f020808200317w71047efci51b23036e15c2eb4@mail.gmail.com>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
	 <20080819210545.27199.5276.sendpatchset@lts-notebook>
	 <84144f020808200317w71047efci51b23036e15c2eb4@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 20 Aug 2008 12:26:33 -0400
Message-Id: <1219249593.6075.18.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-20 at 13:17 +0300, Pekka Enberg wrote:
> Hi Lee,
> 
> On Wed, Aug 20, 2008 at 12:05 AM, Lee Schermerhorn
> <lee.schermerhorn@hp.com> wrote:
> > Against:  2.6.27-rc3-mmotm-080816-0202
> >
> > Rework Posix error return for mlock().
> >
> > Translate get_user_pages() error to posix specified error codes.
> 
> It would be nice if the changelog explained why this matters (i.e. why
> we need this).

OK.  This patch is actually moving code that was introduced upstream in
another earlier patch that explained the rationale.  I'll include a
pointer to that and a summary of why.

I need to respin this patch anyway.  I'll update the description when I
resend.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
