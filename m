Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2BA66B02F4
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 14:48:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r30so18780178qtc.5
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 11:48:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q1si4041103qtd.284.2017.07.07.11.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 11:48:49 -0700 (PDT)
Date: Fri, 7 Jul 2017 14:48:44 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/3] Protectable memory support
Message-ID: <20170707184843.GA3113@redhat.com>
References: <20170705134628.3803-1-igor.stoppa@huawei.com>
 <20170705134628.3803-2-igor.stoppa@huawei.com>
 <20170706162742.GA2919@redhat.com>
 <1665fd00-5908-2399-577d-1972c7d1c63b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1665fd00-5908-2399-577d-1972c7d1c63b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org, penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Fri, Jul 07, 2017 at 11:42:09AM +0300, Igor Stoppa wrote:
> On 06/07/17 19:27, Jerome Glisse wrote:
> > On Wed, Jul 05, 2017 at 04:46:26PM +0300, Igor Stoppa wrote:

[...]

> > Yet another way is to use some of the free struct page fields ie
> > when a page is allocated for vmalloc i think most of struct page
> > fields are unuse (mapping, index, lru, ...). It would be better
> > to use those rather than adding a page flag.
> 
> Like introducing an unnamed union? Some sort of vmalloc_page_subtype?
> If that is what you are proposing, I agree that it would work in a
> similar fashion as what I have now, but without introducing the overhead
> of the extra page flag.

No need to introduce unamed union or anything. Just use one of the
existing field for install you can make page->mapping point to the
pmalloc pool structure. Or you can store a unique key value.

I believe there is enough unuse field that for vmalloc pages that
you should find one you can use. Just add some documentation in
mm_types.h so people are aware of alternate use for the field you
are using.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
