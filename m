Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3849A6B0246
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 09:29:08 -0400 (EDT)
Date: Wed, 7 Jul 2010 09:27:44 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V3 3/8] Cleancache: core ops functions and configuration
Message-ID: <20100707132744.GB4823@phenom.dumpdata.com>
References: <20100621231939.GA19505@ca-server1.us.oracle.com>
 <1277223988.9782.20.camel@nimitz>
 <20100706205121.GA32627@phenom.dumpdata.com>
 <4C33D240.80102@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C33D240.80102@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Dave Hansen <dave@sr71.net>, Dan Magenheimer <dan.magenheimer@oracle.com>, chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

> > Can you reference with a link or a git branch the patches that utilize
> > this?
> > 
> > And also mention that in the 0/X patch so that folks can reference your
> > cleancache implementation?
> > 
> >
> 
> FYI.
> 
> I am working on 'zcache' which uses cleancache_ops to provide page cache
> compression support. I will be posting it to LKML before end of next week.

Yes! That too, please. Thanks for pointing this out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
