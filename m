Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 727996B0002
	for <linux-mm@kvack.org>; Tue, 21 May 2013 06:26:53 -0400 (EDT)
Date: Tue, 21 May 2013 12:26:48 +0200
From: Karel Zak <kzak@redhat.com>
Subject: Re: [RFC PATCH 02/02] swapon: add "cluster-discard" support
Message-ID: <20130521102648.GB11774@x2.net.home>
References: <cover.1369092449.git.aquini@redhat.com>
 <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
 <519AC7B3.5060902@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519AC7B3.5060902@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rafael Aquini <aquini@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

On Mon, May 20, 2013 at 09:02:43PM -0400, KOSAKI Motohiro wrote:
> > -	if (fl_discard)
> > +	if (fl_discard) {
> >  		flags |= SWAP_FLAG_DISCARD;
> > +		if (fl_discard > 1)
> > +			flags |= SWAP_FLAG_DISCARD_CLUSTER;
> 
> This is not enough, IMHO. When running this code on old kernel, swapon() return EINVAL.
> At that time, we should fall back swapon(0x10000).

 Hmm.. currently we don't use any fallback for any swap flag (e.g.
 0x10000) for compatibility with old kernels. Maybe it's better to
 keep it simple and stupid and return an error message than introduce
 any super-smart semantic to hide incompatible fstab configuration.

    Karel
 
-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
