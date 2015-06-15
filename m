Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 14F9C6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 17:55:39 -0400 (EDT)
Received: by igbos3 with SMTP id os3so30013954igb.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:55:38 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id a11si11009692icm.68.2015.06.15.14.55.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 14:55:38 -0700 (PDT)
Received: by iebgx4 with SMTP id gx4so1257618ieb.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 14:55:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150615214338.GH18909@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
	<1434388931-24487-2-git-send-email-aarcange@redhat.com>
	<CA+55aFzdZJw7Ot7=PYyyskNhkv=H+NPzoF6rKtb6oMyzkuQ-=Q@mail.gmail.com>
	<20150615214338.GH18909@redhat.com>
Date: Mon, 15 Jun 2015 11:55:38 -1000
Message-ID: <CA+55aFxKz5eONz1g57ccZ8b=6ivouQOapBtVjt7U3aOtrRgw8Q@mail.gmail.com>
Subject: Re: [PATCH 1/7] userfaultfd: require UFFDIO_API before other ioctls
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: multipart/alternative; boundary=90e6ba6e8adea8f885051895841d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, qemu-devel@nongnu.org, Paolo Bonzini <pbonzini@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org

--90e6ba6e8adea8f885051895841d
Content-Type: text/plain; charset=UTF-8

On Jun 15, 2015 11:43 AM, "Andrea Arcangeli" <aarcange@redhat.com> wrote:
>
> Several times I got very hardly reproducible bugs noticed purely
> because of BUG_ON (not VM_BUG_ON)

Feel free to use them while developing. Don't send me patches with your
broken debug code, though.

For users, a dead machine means that it is less likely you will ever get a
bug report. People set "reboot on oops", and when running X is not always
something that can be seen anyway. They'll just see a rebooting or a dead
machine, and not send you any debug output.

This is not negotiable. Seriously. Get rid of the BUG_ON if you expect your
patches to be merged mainline.

Also, even for debugging, using something like

    if (WARN_ON_ONCE(...))
         return -EINVAL;

is the right thing to do. Then you can unwind locks etc, and return
cleanly, and you'll only get one warning rather than a stream of them etc.

So stop making excuses for your bad BUG_ON use. Do it in private where
nobody can see your perversions, or do it right.

        Linus

--90e6ba6e8adea8f885051895841d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On Jun 15, 2015 11:43 AM, &quot;Andrea Arcangeli&quot; &lt;<a href=3D"mailt=
o:aarcange@redhat.com">aarcange@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt; Several times I got very hardly reproducible bugs noticed purely<br>
&gt; because of BUG_ON (not VM_BUG_ON)</p>
<p dir=3D"ltr">Feel free to use them while developing. Don&#39;t send me pa=
tches with your broken debug code, though.</p>
<p dir=3D"ltr">For users, a dead machine means that it is less likely you w=
ill ever get a bug report. People set &quot;reboot on oops&quot;, and when =
running X is not always something that can be seen anyway. They&#39;ll just=
 see a rebooting or a dead machine, and not send you any debug output.</p>
<p dir=3D"ltr">This is not negotiable. Seriously. Get rid of the BUG_ON if =
you expect your patches to be merged mainline.</p>
<p dir=3D"ltr">Also, even for debugging, using something like</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0 if (WARN_ON_ONCE(...))<br>
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return -EINVAL;</p>
<p dir=3D"ltr">is the right thing to do. Then you can unwind locks etc, and=
 return cleanly, and you&#39;ll only get one warning rather than a stream o=
f them etc.</p>
<p dir=3D"ltr">So stop making excuses for your bad BUG_ON use. Do it in pri=
vate where nobody can see your perversions, or do it right.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>

--90e6ba6e8adea8f885051895841d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
