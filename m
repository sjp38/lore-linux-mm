Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3506B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:04:45 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m68so3272919ith.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:04:45 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id o24si10667315ioi.146.2017.06.19.16.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:04:44 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id w12so19691793pfk.0
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:04:44 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 10/10] x86/mm: Try to preserve old TLB entries using
 PCID
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <29636D5E-53D4-47B1-8F72-8DD0FAE58A60@gmail.com>
Date: Mon, 19 Jun 2017 16:04:41 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <63A46FD8-1F25-4CE2-8C0C-6E57ECB9470C@gmail.com>
References: <cover.1497415951.git.luto@kernel.org>
 <35264bd304c93f6d3cfff2329e3e01b084598ea1.1497415951.git.luto@kernel.org>
 <740B1D51-B801-48C9-A4C9-F31B34A09AEF@gmail.com>
 <CALCETrV=v_4Ss4VSSW0CJFWCnr0Ks9c0K1W55wipOnL8sStOpg@mail.gmail.com>
 <29636D5E-53D4-47B1-8F72-8DD0FAE58A60@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

Nadav Amit <nadav.amit@gmail.com> wrote:

>>=20
> Just to clarify: I asked since I don=E2=80=99t understand how the =
interaction with
> PCID-unaware CR3 users go. Specifically, IIUC, =
arch_efi_call_virt_teardown()
> can reload CR3 with an old PCID value. No?

Please ignore this email. I realized it is not a problem.

Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
