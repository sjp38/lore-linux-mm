Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7B796B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 14:06:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n18-v6so25645164iog.10
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 11:06:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i124-v6sor1747668itf.75.2018.07.12.11.06.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 11:06:19 -0700 (PDT)
MIME-Version: 1.0
References: <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz> <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
 <20180711102139.GG20050@dhcp22.suse.cz> <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
 <1531330947.3260.13.camel@HansenPartnership.com> <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com> <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com> <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
In-Reply-To: <1531416080.18255.8.camel@HansenPartnership.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jul 2018 11:06:08 -0700
Message-ID: <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Content-Type: multipart/mixed; boundary="00000000000056798e0570d138d2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

--00000000000056798e0570d138d2
Content-Type: text/plain; charset="UTF-8"

On Thu, Jul 12, 2018 at 10:21 AM James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> On Thu, 2018-07-12 at 09:49 -0700, Matthew Wilcox wrote:
> >
> > I don't know that it does work.  Or that it works well.
>
> I'm not claiming the general heuristics are perfect (in fact I know we
> still have a lot of problems with dirty reclaim and writeback).

I think this whole "this is about running out of memory" approach is wrong.

We *should* handle that well. Or well enough in practice, at least.

Do we? Maybe not. Should the dcache be the one area to be policed and
worked around? Probably not.

But there may be other reasons to just limit negative dentries.

What does the attached program do to people? It's written to be
intentionally annoying to the dcache.

               Linus

--00000000000056798e0570d138d2
Content-Type: text/x-csrc; charset="US-ASCII"; name="t.c"
Content-Disposition: attachment; filename="t.c"
Content-Transfer-Encoding: base64
Content-ID: <f_jjiv6g8e0>
X-Attachment-Id: f_jjiv6g8e0

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHVuaXN0ZC5o
PgojaW5jbHVkZSA8ZmNudGwuaD4KI2luY2x1ZGUgPHN0cmluZy5oPgoKc3RhdGljIHZvaWQgZGll
KGNvbnN0IGNoYXIgKm1zZykKewoJZnB1dHMobXNnLCBzdGRlcnIpOwoJZXhpdCgxKTsKfQoKLyoK
ICogVXNlIGEgImxvbmdpc2giIGZpbGVuYW1lIHRvIG1ha2UgbW9yZSB0cm91YmxlIGZvciB0aGUg
ZGNhY2hlLgogKgogKiBUaGUgaW5saW5lIGxlbmd0aCBpcyAzMi00MCBieXRlcyBkZXBlbmRpbmcg
b24ga2VybmVsIGNvbmZpZywKICogc28gbWFrZSBpdCBsYXJnZXIgdGhhbiB0aGF0LgogKi8KaW50
IG1haW4odm9pZCkKewoJaW50IGk7CgljaGFyIGJ1ZmZlcls2NF07CgoJbWVtc2V0KGJ1ZmZlciwg
J2EnLCBzaXplb2YoYnVmZmVyKSk7CglidWZmZXJbNjNdID0gMDsKCglmb3IgKGkgPSAwOyBpIDwg
MTAwMDAwMDAwOyBpKyspIHsKCQlzbnByaW50ZihidWZmZXIrNDAsIHNpemVvZihidWZmZXIpLTQw
LCAiLSUwOGQiLCBpKTsKCQlpZiAob3BlbihidWZmZXIsIE9fUkRPTkxZKSA+PSAwKQoJCQlkaWUo
IllvdSdyZSBtaXNzaW5nIHRoZSBwb2ludFxuIik7Cgl9CglyZXR1cm4gMDsKfQo=
--00000000000056798e0570d138d2--
