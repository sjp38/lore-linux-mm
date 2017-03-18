Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19A3D6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 23:54:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a189so89120898qkc.4
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:54:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z145si7955130qka.13.2017.03.17.20.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 20:54:03 -0700 (PDT)
Date: Fri, 17 Mar 2017 23:54:02 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <511871248.8852779.1489809242452.JavaMail.zimbra@redhat.com>
In-Reply-To: <d1dd967c-69e6-f673-0c88-06bb4e234872@nvidia.com>
References: <1489778823-8694-1-git-send-email-jglisse@redhat.com> <1489778823-8694-3-git-send-email-jglisse@redhat.com> <d1dd967c-69e6-f673-0c88-06bb4e234872@nvidia.com>
Subject: Re: [HMM 2/2] hmm: heterogeneous memory management documentation
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

> On 03/17/2017 12:27 PM, J=C3=A9r=C3=B4me Glisse wrote:
> > This add documentation for HMM (Heterogeneous Memory Management). It
> > presents the motivation behind it, the features necessary for it to
> > be usefull and and gives an overview of how this is implemented.
>=20
> For this patch, I will leave it to others to decide how to proceed, given=
 the
> following:
>=20
> 1. This hmm.txt has a lot of critical information in it.
>=20
> 2. It is, however, more of a first draft than a final draft: lots of erro=
rs
> in each sentence, and
> lots of paragraphs that need re-doing, for example. After a quick pass
> through a few other
> Documentation/vm/*.txt documents to gage the quality bar, I am inclined t=
o
> recommend (or do) a
> second draft of this, before submitting it.
>=20
> Since I'm the one being harsh here (and Jerome, you already know I'm hars=
h!
> haha), I can provide a
> second draft. But it won't look much like the current draft, so brace
> yourself before saying yes... :)

Feel free to take a stab at it :)

Cheers,
J=C3=A9r=C3=B4me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
