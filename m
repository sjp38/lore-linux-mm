Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBB16B02A3
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 13:44:30 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <537098fb-f049-482a-97cf-b3695bf2c340@default>
Date: Fri, 23 Jul 2010 10:43:17 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 0/8] Cleancache: overview
References: <20100621231809.GA11111@ca-server1.us.oracle.com4C49468B.40307@vflare.org>
 <840b32ff-a303-468e-9d4e-30fc92f629f8@default>
 <20100723140440.GA12423@infradead.org>
 <364c83bd-ccb2-48cc-920d-ffcf9ca7df19@default 4C49AFAE.1070300@vflare.org>
In-Reply-To: <4C49AFAE.1070300@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org, Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, adilger@Sun.COM, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

> From: Nitin Gupta [mailto:ngupta@vflare.org]
> Sent: Friday, July 23, 2010 9:05 AM
> To: Dan Magenheimer
> Cc: Christoph Hellwig; akpm@linux-foundation.org; Chris Mason;
> viro@zeniv.linux.org.uk; adilger@sun.com; tytso@mit.edu;
> mfasheh@suse.com; Joel Becker; matthew@wil.cx; linux-
> btrfs@vger.kernel.org; linux-kernel@vger.kernel.org; linux-
> fsdevel@vger.kernel.org; linux-ext4@vger.kernel.org; ocfs2-
> devel@oss.oracle.com; linux-mm@kvack.org; jeremy@goop.org;
> JBeulich@novell.com; Kurt Hackel; npiggin@suse.de; Dave Mccracken;
> riel@redhat.com; avi@redhat.com; Konrad Wilk
> Subject: Re: [PATCH V3 0/8] Cleancache: overview
>=20
> On 07/23/2010 08:14 PM, Dan Magenheimer wrote:
> >> From: Christoph Hellwig [mailto:hch@infradead.org]
>=20
>=20
> >> Also making the ops vector global is just a bad idea.
> >> There is nothing making this sort of caching inherently global.
> >
> > I'm not sure I understand your point, but two very different
> > users of cleancache have been provided, and more will be
> > discussed at the MM summit next month.
> >
> > Do you have a suggestion on how to avoid a global ops
> > vector while still serving the needs of both existing
> > users?
>=20
> Maybe introduce cleancache_register(struct cleancache_ops *ops)?
> This will allow making cleancache_ops non-global. No value add
> but maybe that's cleaner?

Oh, OK, that seems reasonable.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
