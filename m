Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id EB9A082F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 19:59:19 -0400 (EDT)
Received: by oiad129 with SMTP id d129so14742313oia.0
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:59:19 -0700 (PDT)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id a11si18733101oih.138.2015.10.28.16.59.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 16:59:19 -0700 (PDT)
Received: by obbza9 with SMTP id za9so20581743obb.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 16:59:19 -0700 (PDT)
MIME-Version: 1.0
References: <1446067520-31806-1-git-send-email-dcashman@android.com> <871tcewoso.fsf@x220.int.ebiederm.org>
In-Reply-To: <871tcewoso.fsf@x220.int.ebiederm.org>
From: Jeffrey Vander Stoep <jeffv@google.com>
Date: Wed, 28 Oct 2015 23:59:09 +0000
Message-ID: <CABXk95C4+nPOe2vDEHWPU9eP6nnY3yq=aJnYdEv=LmLyLk8F1g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Content-Type: multipart/alternative; boundary=001a11c2c8d4891b04052332fb04
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Daniel Cashman <dcashman@android.com>
Cc: linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, nnk@google.com, dcashman <dcashman@google.com>

--001a11c2c8d4891b04052332fb04
Content-Type: text/plain; charset=UTF-8

>
> As it sits this looks like a patchset that does not meaninfully bisect,
> and would result in code that is hard to trace and understand.
>

I believe the intent is to follow up with more architecture specific
patches to allow each architecture to define the number of bits to use
(min, max, and default) since these values are architecture dependent.
Arm64 patch should be forthcoming, and others after that. With that in
mind, would you still prefer to have the sysctl code in the arm-specific
patch?

--001a11c2c8d4891b04052332fb04
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">=
As it sits this looks like a patchset that does not meaninfully bisect,<br>
and would result in code that is hard to trace and understand.<br></blockqu=
ote><div><br></div><div>I believe the intent is to follow up with more arch=
itecture specific patches to allow each architecture to define the number o=
f bits to use (min, max, and default) since these values are architecture d=
ependent. Arm64 patch should be forthcoming, and others after that. With th=
at in mind, would you still prefer to have the=C2=A0sysctl code in the arm-=
specific patch?</div></div></div>

--001a11c2c8d4891b04052332fb04--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
