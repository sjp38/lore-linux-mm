Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4DC6B029C
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 00:26:42 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id f187so171958030qkd.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 21:26:42 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id u5si13356727qkb.5.2016.09.25.21.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 21:26:41 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id 38so5463161qte.2
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 21:26:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzOvPJbVFvssmiOHuCKG_z-FbGO8-EzVnShDCVmAc1MQQ@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CA+55aFwNYAFc4KePvx50kwZ3A+8yvCCK_6nYYxG9fqTPhFzQoQ@mail.gmail.com>
 <DM2PR21MB0089CA7DCF4845DB02E0E05FCBC80@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CA+55aFwiro5MvOozcF50z4kMBk7rVBViLw8yXX1w-1mCZVAsDA@mail.gmail.com>
 <20160924210443.GA106728@black.fi.intel.com> <CA+55aFzOvPJbVFvssmiOHuCKG_z-FbGO8-EzVnShDCVmAc1MQQ@mail.gmail.com>
From: Ross Zwisler <zwisler@gmail.com>
Date: Sun, 25 Sep 2016 22:26:40 -0600
Message-ID: <CAOxpaSVnjq9EWHTd+dOChkxg_XN1BNpQxZ30O1ttunUxQ3cR6w@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: multipart/alternative; boundary=94eb2c19078ae62b7b053d618856
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

--94eb2c19078ae62b7b053d618856
Content-Type: text/plain; charset=UTF-8

On Saturday, September 24, 2016, Linus Torvalds <
torvalds@linux-foundation.org> wrote:

> On Sat, Sep 24, 2016 at 2:04 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com <javascript:;>> wrote:
> >
> > Well, my ext4-with-huge-pages patchset[1] uses multi-order entries.
> > It also converts shmem-with-huge-pages and hugetlb to them.
>
> Ok, so that code actually has a chance of being used. I guess we'll
> not remove it. But I *would* like this subtle issue to have a comment
> around that odd cast/and/mask thing.
>
>             Linus
>

My DAX PMD patches will use multi-order entries as well.

--94eb2c19078ae62b7b053d618856
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Saturday, September 24, 2016, Linus Torvalds &lt;<a href=3D"mailto:torva=
lds@linux-foundation.org">torvalds@linux-foundation.org</a>&gt; wrote:<br><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex">On Sat, Sep 24, 2016 at 2:04 PM, Kirill A. Sh=
utemov<br>
&lt;<a href=3D"javascript:;" onclick=3D"_e(event, &#39;cvml&#39;, &#39;kiri=
ll.shutemov@linux.intel.com&#39;)">kirill.shutemov@linux.intel.com</a>&gt; =
wrote:<br>
&gt;<br>
&gt; Well, my ext4-with-huge-pages patchset[1] uses multi-order entries.<br=
>
&gt; It also converts shmem-with-huge-pages and hugetlb to them.<br>
<br>
Ok, so that code actually has a chance of being used. I guess we&#39;ll<br>
not remove it. But I *would* like this subtle issue to have a comment<br>
around that odd cast/and/mask thing.<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Linus<br>
</blockquote><div><br></div><div>My DAX PMD patches will use multi-order en=
tries as well.<span></span>=C2=A0</div>

--94eb2c19078ae62b7b053d618856--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
