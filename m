Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C82E6B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:52:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j17so7566335qth.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:52:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m189sor5541563qkc.80.2018.03.16.14.51.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 14:51:59 -0700 (PDT)
MIME-Version: 1.0
References: <20180316182512.118361-1-wvw@google.com> <20180316143306.dd98055a170497e9535cc176@linux-foundation.org>
In-Reply-To: <20180316143306.dd98055a170497e9535cc176@linux-foundation.org>
From: Wei Wang <wei.vince.wang@gmail.com>
Date: Fri, 16 Mar 2018 21:51:48 +0000
Message-ID: <CAMFybE7EKyJMmR=Ntn1UX1ZMWJ=32v9G_kYdXh4LhinDv_JO8Q@mail.gmail.com>
Subject: Re: [PATCH] mm: add config for readahead window
Content-Type: multipart/alternative; boundary="94eb2c04e5521a064805678e9eb6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Wang <wvw@google.com>, gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--94eb2c04e5521a064805678e9eb6
Content-Type: text/plain; charset="UTF-8"

On Fri, Mar 16, 2018, 14:33 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 16 Mar 2018 11:25:08 -0700 Wei Wang <wvw@google.com> wrote:
>
> > Change VM_MAX_READAHEAD value from the default 128KB to a configurable
> > value. This will allow the readahead window to grow to a maximum size
> > bigger than 128KB during boot, which could benefit to sequential read
> > throughput and thus boot performance.
>
> You can presently run ioctl(BLKRASET) against the block device?
>

Yeah we are doing tuning in userland after init. But this is something we
thought could help in very early stage.

>

--94eb2c04e5521a064805678e9eb6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">=
On Fri, Mar 16, 2018, 14:33 Andrew Morton &lt;<a href=3D"mailto:akpm@linux-=
foundation.org">akpm@linux-foundation.org</a>&gt; wrote:<br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">On Fri, 16 Mar 2018 11:25:08 -0700 Wei Wang &lt;<a hr=
ef=3D"mailto:wvw@google.com" target=3D"_blank" rel=3D"noreferrer">wvw@googl=
e.com</a>&gt; wrote:<br>
<br>
&gt; Change VM_MAX_READAHEAD value from the default 128KB to a configurable=
<br>
&gt; value. This will allow the readahead window to grow to a maximum size<=
br>
&gt; bigger than 128KB during boot, which could benefit to sequential read<=
br>
&gt; throughput and thus boot performance.<br>
<br>
You can presently run ioctl(BLKRASET) against the block device?<br></blockq=
uote></div></div><div dir=3D"auto"><br></div><div dir=3D"auto">Yeah we are =
doing tuning in userland after init. But this is something we thought could=
 help in very early stage.</div><div dir=3D"auto"><div class=3D"gmail_quote=
"><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex">
</blockquote></div></div></div>

--94eb2c04e5521a064805678e9eb6--
