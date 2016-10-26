Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BBE7B6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:14:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id t132so5692360itb.11
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 21:14:16 -0700 (PDT)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id h134si763053iof.237.2016.10.25.21.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 21:14:16 -0700 (PDT)
Received: by mail-it0-x229.google.com with SMTP id m138so7256169itm.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 21:14:16 -0700 (PDT)
Subject: Re: [PATCHv4 18/43] block: define BIO_MAX_PAGES to HPAGE_PMD_NR if huge page cache enabled
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_5A8DFCBE-21B1-4B71-A2A9-6CB060976717"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20161025125431.GA22787@node.shutemov.name>
Date: Tue, 25 Oct 2016 22:13:13 -0600
Message-Id: <BD27B76A-AF34-48B9-8D4F-F69AD2C17C66@dilger.ca>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com> <20161025001342.76126-19-kirill.shutemov@linux.intel.com> <20161025072122.GA21708@infradead.org> <20161025125431.GA22787@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Hellwig <hch@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org


--Apple-Mail=_5A8DFCBE-21B1-4B71-A2A9-6CB060976717
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Oct 25, 2016, at 6:54 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> 
> On Tue, Oct 25, 2016 at 12:21:22AM -0700, Christoph Hellwig wrote:
>> On Tue, Oct 25, 2016 at 03:13:17AM +0300, Kirill A. Shutemov wrote:
>>> We are going to do IO a huge page a time. So we need BIO_MAX_PAGES to be
>>> at least HPAGE_PMD_NR. For x86-64, it's 512 pages.
>> 
>> NAK.  The maximum bio size should not depend on an obscure vm config,
>> please send a standalone patch increasing the size to the block list,
>> with a much long explanation.  Also you can't simply increase the size
>> of the largers pool, we'll probably need more pools instead, or maybe
>> even implement a similar chaining scheme as we do for struct
>> scatterlist.
> 
> The size of required pool depends on architecture: different architectures
> has different (huge page size)/(base page size).
> 
> Would it be okay if I add one more pool with size equal to HPAGE_PMD_NR,
> if it's bigger than than BIO_MAX_PAGES and huge pages are enabled?

Why wouldn't you have all the pool sizes in between?  Definitely 1MB has
been too small already for high-bandwidth IO.  I wouldn't mind BIOs up to
4MB or larger since most high-end RAID hardware does best with 4MB IOs.

Cheers, Andreas






--Apple-Mail=_5A8DFCBE-21B1-4B71-A2A9-6CB060976717
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBWBAtWnKl2rkXzB/gAQi8tA/+IKGZ0QC1GIU3Y5HRATtiqNxImtCde9PD
IzQe3/7A+ohno8h3xarTqHJhTNLDKnd6u+ARqcbjaqxWQkDfee8QHVU5T/R5GLU/
TWmdYeBKGYffejgBBNy1MCuU7l72gUlHiCS0+m5kY0YhMoNwarRyb5hVLJk6y1Og
uTWwlCJV9kz+GVz/Nc+Tk83v3oJy6Zon2o19L6iP/PrcRGTqHXhbvyJ8zdbs4aDc
MM34IBv585W961LF9VWBfCd0+cDtv/Q0Smsjv9p67xQZoWMfC9R2QzPAu5tWpawa
Q49D7sh9LXnRcqVXgHmt/4oCUcw/f1bLZ7I8pfaT0sooIC7hcsu1XpempADDQBWI
ghE1Gx1eMCWGreY5VfJ7bqjadh86LrtNpjHHtMUj1VmC7lwGiBnMMvIr+iFLve9q
W3VxsIZC6c1Vl7O7PbKGuc2804c0zXbSNSsZg39xbjnAh1ZMeR4NqHYIpR/BXUhg
nKrfWU/dLmn9j3niF6mrEmThhEgLnqqWJhVtd8X7L/ahxGVjcFlD0HnfpOB7MqKK
Sh5X5lgNKrsrfkFPbLd9FWGc9NQMAq5qK1kKof1AJhLtXg3nfkV6sRon/Gzio584
7zZNi6l69kjvMRbvxKw8LTi1Mqk0k5Fohp2ljAIYZDs9E6Qk7kBTYqIPN1I/BrqP
vcDB7Jjn88A=
=sSD6
-----END PGP SIGNATURE-----

--Apple-Mail=_5A8DFCBE-21B1-4B71-A2A9-6CB060976717--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
