Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 442CF6B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 07:35:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g75so18365458pfg.4
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:35:17 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [65.50.211.136])
        by mx.google.com with ESMTPS id g3si53761plb.50.2017.10.24.04.35.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 04:35:15 -0700 (PDT)
Date: Tue, 24 Oct 2017 13:32:51 +0200
In-Reply-To: <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com> <20171003082754.no6ym45oirah53zp@node.shutemov.name> <20171017154241.f4zaxakfl7fcrdz5@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 0/6] Boot-time switching between 4- and 5-level paging for 4.15, Part 1
From: hpa@zytor.com
Message-ID: <D692A598-D2C7-433A-84E6-D310299935CC@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On October 17, 2017 5:42:41 PM GMT+02:00, "Kirill A=2E Shutemov" <kirill@sh=
utemov=2Ename> wrote:
>On Tue, Oct 03, 2017 at 11:27:54AM +0300, Kirill A=2E Shutemov wrote:
>> On Fri, Sep 29, 2017 at 05:08:15PM +0300, Kirill A=2E Shutemov wrote:
>> > The first bunch of patches that prepare kernel to boot-time
>switching
>> > between paging modes=2E
>> >=20
>> > Please review and consider applying=2E
>>=20
>> Ping?
>
>Ingo, is there anything I can do to get review easier for you?
>
>I hoped to get boot-time switching code into v4=2E15=2E=2E=2E

One issue that has come up with this is what happens if the kernel is load=
ed above 4 GB and we need to switch page table mode=2E  In that case we nee=
d enough memory below the 4 GB point to hold a root page table (since we ca=
n't write the upper half of cr3 outside of 64-bit mode) and a handful of in=
structions=2E

We have no real way to know for sure what memory is safe without parsing a=
ll the memory maps and map out all the data structures that The bootloader =
has left for the kernel=2E  I'm thinking that the best way to deal with thi=
s is to add an entry in setup_data to provide a pointers, with the kernel h=
eader specifying a necessary size and alignment=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
