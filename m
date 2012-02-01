Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 0794A6B002C
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 03:44:58 -0500 (EST)
Received: by obbta7 with SMTP id ta7so1387733obb.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 00:44:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120201083032.GA6774@localhost>
References: <20120201063420.GA10204@darkstar.nay.redhat.com>
	<CAOJsxLGVS3bK=hiKJu4NwTv-Nf8TCSAEL4reSZoY4=44hPt8rA@mail.gmail.com>
	<4F28EC9D.7000907@redhat.com>
	<20120201083032.GA6774@localhost>
Date: Wed, 1 Feb 2012 10:44:58 +0200
Message-ID: <CAOJsxLEnn-5X5q=1p07twxm5EuyQo7cOBBfFQXUeMGi3Pvd46w@mail.gmail.com>
Subject: Re: [PATCH] move vm tools from Documentation/vm/ to tools/
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Wed, Feb 1, 2012 at 10:30 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Will git-mv end up with a better commit?

Just use

    git format-patch -C

to generate the patch and it should be fine.

>> BTW, I think tools/slub/slabinfo.c should be included in tools/vm/ as
>> well, will move it in v2 patch
>
> CC Christoph. Maybe not a big deal since it's already under tools/.

I'm certainly fine with moving it to tools/vm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
