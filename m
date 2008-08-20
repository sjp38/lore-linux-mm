Received: by wa-out-1112.google.com with SMTP id m28so91807wag.8
        for <linux-mm@kvack.org>; Wed, 20 Aug 2008 03:17:17 -0700 (PDT)
Message-ID: <84144f020808200317w71047efci51b23036e15c2eb4@mail.gmail.com>
Date: Wed, 20 Aug 2008 13:17:17 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 6/6] Mlock: make mlock error return Posixly Correct
In-Reply-To: <20080819210545.27199.5276.sendpatchset@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
	 <20080819210545.27199.5276.sendpatchset@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, riel@redhat.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Lee,

On Wed, Aug 20, 2008 at 12:05 AM, Lee Schermerhorn
<lee.schermerhorn@hp.com> wrote:
> Against:  2.6.27-rc3-mmotm-080816-0202
>
> Rework Posix error return for mlock().
>
> Translate get_user_pages() error to posix specified error codes.

It would be nice if the changelog explained why this matters (i.e. why
we need this).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
