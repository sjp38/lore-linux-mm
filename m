Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6A206B0008
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 12:17:04 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c37so4106501wra.5
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 09:17:04 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id m187si15889469wmg.35.2018.02.20.09.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 09:17:03 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <20180126053542.GA30189@bombadil.infradead.org>
 <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
 <b75b5903-0177-8ad9-5c2b-fc63438fb5f2@huawei.com>
 <CAFUG7CfrCpcbwgf5ixMC5EZZgiVVVp1NXhDHK1UoJJcC08R2qQ@mail.gmail.com>
 <8818bfd4-dd9f-f279-0432-69b59531bd41@huawei.com>
 <CAFUG7CeUhFcvA82uZ2ZH1j_6PM=aBo4XmYDN85pf8G0gPU44dg@mail.gmail.com>
 <17e5b515-84c8-dca2-1695-cdf819834ea2@huawei.com>
 <CAGXu5j+LS1pgOOroi7Yxp2nh=DwtTnU3p-NZa6bQu_wkvvVkwg@mail.gmail.com>
 <414027d3-dd73-cf11-dc2a-e8c124591646@redhat.com>
 <5a83024c.64369d0a.a1e94.cdd6SMTPIN_ADDED_BROKEN@mx.google.com>
 <13a50f85-bbd8-5d78-915a-a29c4a9f0c32@redhat.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <7972cf4d-dfb2-6682-b1cb-e514a41196a6@huawei.com>
Date: Tue, 20 Feb 2018 19:16:38 +0200
MIME-Version: 1.0
In-Reply-To: <13a50f85-bbd8-5d78-915a-a29c4a9f0c32@redhat.com>
Content-Type: text/plain; charset="gbk"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>
Cc: Boris Lukashev <blukashev@sempervictus.com>, Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel
 Hardening <kernel-hardening@lists.openwall.com>



On 13/02/18 20:10, Laura Abbott wrote:
> On 02/13/2018 07:20 AM, Igor Stoppa wrote:
>> Why alterations of page properties are not considered a risk and the physmap is?
>> And how would it be easier (i suppose) to attack the latter?
> 
> Alterations are certainly a risk but with the physmap the
> mapping is already there. Find the address and you have
> access vs. needing to actually modify the properties
> then do the access. I could also be complete off base
> on my threat model here so please correct me if I'm
> wrong.

It's difficult for me to comment on this without knowing *how* the
attack would be performed, in your model.

Ex: my expectation is that the attacked has R/W access to kernel data
and has knowledge of the location of static variables.

This is not just a guess, but a real-life scenario, found in attacks
that, among other things, are capable of disabling SELinux, to proceed
toward gaining full root capability.

At that point, I think that variables which are allocated dynamically,
in vmalloc address space, are harder to locate, because of the virtual
mapping and the randomness of the address chosen (this I have not
confirmed yet, but I suppose there is some randomness in picking the
address to assign to a certain allocation request to vmalloc, otherwise,
it could be added).

> I think your other summaries are good points though
> and should go in the cover letter.

Ok, I'm just afraid it risks becoming a lengthy dissertation :-)

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
