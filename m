Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 011F36B00F7
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 13:08:04 -0500 (EST)
Message-ID: <1329502078.2293.286.camel@twins>
Subject: Re: [PATCH 1/2] rmap: Staticize page_referenced_file and
 page_referenced_anon
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 17 Feb 2012 19:07:58 +0100
In-Reply-To: <CAFPAmTRrW4rAiC6UPGCFWChyuAjtbn7pkXRm3L2_SYdrRQCBZQ@mail.gmail.com>
References: <1329488869-7270-1-git-send-email-consul.kautuk@gmail.com>
	 <1329491708.2293.277.camel@twins>
	 <CAFPAmTRrW4rAiC6UPGCFWChyuAjtbn7pkXRm3L2_SYdrRQCBZQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-02-17 at 10:19 -0500, Kautuk Consul wrote:
> > Also, if they're static and there's only a single callsite, gcc will
> > already inline them, does this patch really make a difference?
>=20
> I just sent this patch for what I thought was "correctness", but I guess
> we can let this be if you are absolutely sure that all GCC cross compiler=
s
> for all platforms will guarantee inlining.=20

Typically we don't explicitly inline such large functions, unless we
need it for performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
