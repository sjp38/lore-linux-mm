Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A32D16B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 03:14:17 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2789389obb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 00:14:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1336029206.13013.11.camel@sauron.fi.intel.com>
References: <1335932890-25294-1-git-send-email-minchan@kernel.org>
	<20120502124610.175e099c.akpm@linux-foundation.org>
	<4FA1D93C.9000306@kernel.org>
	<Pine.LNX.4.64.1205022241560.18540@cobra.newdream.net>
	<CAPa8GCCzyB7iSX+wTzsqfe7GHvfWT2wT4aQgK30ycRnkc_BNAQ@mail.gmail.com>
	<1336029206.13013.11.camel@sauron.fi.intel.com>
Date: Thu, 3 May 2012 17:14:16 +1000
Message-ID: <CAPa8GCDzgbQ5T-4eR942KswxXwRE69rwV2CKgho6LOV-us5RDw@mail.gmail.com>
Subject: Re: [PATCH] vmalloc: add warning in __vmalloc
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dedekind1@gmail.com
Cc: Sage Weil <sage@newdream.net>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com, rientjes@google.com, Neil Brown <neilb@suse.de>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, Steven Whitehouse <swhiteho@redhat.com>, "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 3 May 2012 17:13, Artem Bityutskiy <dedekind1@gmail.com> wrote:
> On Thu, 2012-05-03 at 16:30 +1000, Nick Piggin wrote:
>> Note that in writeback paths, a "good citizen" filesystem should not require
>> any allocations, or at least it should be able to tolerate allocation failures.
>> So fixing that would be a good idea anyway.
>
> This is a good point, but UBIFS kmallocs(GFP_NOFS) when doing I/O
> because it needs to compress/decompress. But I agree that if kmalloc
> fails, we should have a fall-back reserve buffer protected by a mutex
> for memory pressure situations.

AKA, a mempool :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
