Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC1186B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 04:41:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k2-v6so1824300wrp.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 01:41:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9-v6sor2003485edp.56.2018.06.21.01.41.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 01:41:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180621011656.GA15427@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com> <CAJX1YtaRtCGt7f8H0VEDrDkcOYusB0JoL-CNB_E--MYGhcvbow@mail.gmail.com>
 <20180621011656.GA15427@ming.t460p>
From: Gi-Oh Kim <gi-oh.kim@profitbricks.com>
Date: Thu, 21 Jun 2018 10:40:37 +0200
Message-ID: <CAJX1YtbmOhXh7rfb72hY=d+EumOfacqCxUY_8t0u39+0R4emcw@mail.gmail.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, hch@infradead.org, Al Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, dsterba@suse.cz, ying.huang@intel.com, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, darrick.wong@oracle.com, colyli@suse.de, Filipe Manana <fdmanana@gmail.com>, rdunlap@infradead.org

On Thu, Jun 21, 2018 at 3:17 AM, Ming Lei <ming.lei@redhat.com> wrote:
> On Fri, Jun 15, 2018 at 02:59:19PM +0200, Gi-Oh Kim wrote:
>> >
>> > - bio size can be increased and it should improve some high-bandwidth =
IO
>> > case in theory[4].
>> >
>>
>> Hi,
>>
>> I would like to report your patch set works well on my system based on v=
4.14.48.
>> I thought the multipage bvec could improve the performance of my system.
>> (FYI, my system has v4.14.48 and provides KVM-base virtualization servic=
e.)
>
> Thanks for your test!
>
>>
>> So I did back-porting your patches to v4.14.48.
>> It has done without any serious problem.
>> I only needed to cherry-pick "blk-merge: compute
>> bio->bi_seg_front_size efficiently" and
>> "block: move bio_alloc_pages() to bcache" patches before back-porting
>> to prevent conflicts.
>
> Not sure I understand your point, you have to backport all patches.

Never mind.
I just meant I did backporting for myself and it is still working well.

>
> At least now, BIO_MAX_PAGES can be fixed as 256 in case of CONFIG_THP_SWA=
P,
> otherwise 2 pages may be allocated for holding the bvec table, so tests
> in case of THP_SWAP may be improved.
>
> Also filesystem may support IO to/from THP, and multipage bvec should
> improve this case too.

OK, I got it.
I will find something to use THP_SWAP and run the performance test with it.
Thank you ;-)


--=20
GIOH KIM
Linux Kernel Entwickler

ProfitBricks GmbH
Greifswalder Str. 207
D - 10405 Berlin

Tel:       +49 176 2697 8962
Fax:      +49 30 577 008 299
Email:    gi-oh.kim@profitbricks.com
URL:      https://www.profitbricks.de

Sitz der Gesellschaft: Berlin
Registergericht: Amtsgericht Charlottenburg, HRB 125506 B
Gesch=C3=A4ftsf=C3=BChrer: Achim Weiss, Matthias Steinberg, Christoph Steff=
ens
