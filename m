Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f44.google.com (mail-bk0-f44.google.com [209.85.214.44])
	by kanga.kvack.org (Postfix) with ESMTP id E49806B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 16:21:45 -0500 (EST)
Received: by mail-bk0-f44.google.com with SMTP id mz12so678880bkb.31
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 13:21:45 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id ec9si303643bkc.211.2014.01.23.13.21.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 13:21:43 -0800 (PST)
Date: Thu, 23 Jan 2014 13:21:26 -0800
From: Joel Becker <jlbec@evilplan.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140123212125.GA25376@localhost>
References: <1390411300.2372.33.camel@dabdike.int.hansenpartnership.com>
 <1390413819.1198.20.camel@ret.masoncoding.com>
 <1390414439.2372.53.camel@dabdike.int.hansenpartnership.com>
 <52E00B28.3060609@redhat.com>
 <1390415703.2372.62.camel@dabdike.int.hansenpartnership.com>
 <52E0106B.5010604@redhat.com>
 <1390419019.2372.89.camel@dabdike.int.hansenpartnership.com>
 <20140122115002.bb5d01dee836b567a7aad157@linux-foundation.org>
 <20140123083558.GQ13997@dastard>
 <20140123125550.GB6853@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140123125550.GB6853@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Chris Mason <clm@fb.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, "linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Ric Wheeler <rwheeler@redhat.com>

On Thu, Jan 23, 2014 at 07:55:50AM -0500, Theodore Ts'o wrote:
> On Thu, Jan 23, 2014 at 07:35:58PM +1100, Dave Chinner wrote:
> > > 
> > > I expect it would be relatively simple to get large blocksizes working
> > > on powerpc with 64k PAGE_SIZE.  So before diving in and doing huge
> > > amounts of work, perhaps someone can do a proof-of-concept on powerpc
> > > (or ia64) with 64k blocksize.
> > 
> > Reality check: 64k block sizes on 64k page Linux machines has been
> > used in production on XFS for at least 10 years. It's exactly the
> > same case as 4k block size on 4k page size - one page, one buffer
> > head, one filesystem block.
> 
> This is true for ext4 as well.  Block size == page size support is
> pretty easy; the hard part is when block size > page size, due to
> assumptions in the VM layer that requires that FS system needs to do a
> lot of extra work to fudge around.  So the real problem comes with
> trying to support 64k block sizes on a 4k page architecture, and can
> we do it in a way where every single file system doesn't have to do
> their own specific hacks to work around assumptions made in the VM
> layer.

Yup, ditto for ocfs2.

Joel

-- 

"One of the symptoms of an approaching nervous breakdown is the
 belief that one's work is terribly important."
         - Bertrand Russell 

			http://www.jlbec.org/
			jlbec@evilplan.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
