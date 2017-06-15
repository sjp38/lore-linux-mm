Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7DDC6B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 16:14:10 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i7so20278244ita.10
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 13:14:10 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r77si210854ioe.110.2017.06.15.13.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 13:14:10 -0700 (PDT)
Date: Thu, 15 Jun 2017 16:13:29 -0400
In-Reply-To: <20170615153322.nwylo3dzn4fdx6n6@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net> <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net> <20170614174208.p2yr5exs4b6pjxhf@pd.tnic> <0611d01a-19f8-d6ae-2682-932789855518@amd.com> <20170615094111.wga334kg2bhxqib3@pd.tnic> <921153f5-1528-31d8-b815-f0419e819aeb@amd.com> <20170615153322.nwylo3dzn4fdx6n6@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with memory encryption
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Message-ID: <C1A52990-84AA-4258-B864-0121F5F5C4B5@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On June 15, 2017 11:33:22 AM EDT, Borislav Petkov <bp@alien8=2Ede> wrote:
>On Thu, Jun 15, 2017 at 09:59:45AM -0500, Tom Lendacky wrote:
>> Actually the detection routine, amd_iommu_detect(), is part of the
>> IOMMU_INIT_FINISH macro support which is called early through
>mm_init()
>> from start_kernel() and that routine is called before init_amd()=2E
>
>Ah, we do that there too:
>
>	for (p =3D __iommu_table; p < __iommu_table_end; p++) {
>
>Can't say that that code with the special section and whatnot is
>obvious=2E :-\
>

Patches to make it more obvious would be always welcome!



Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
