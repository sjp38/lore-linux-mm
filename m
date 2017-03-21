Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5206B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 18:25:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t143so122274773pgb.1
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 15:25:20 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id v21si4868061pgh.155.2017.03.21.15.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 15:25:19 -0700 (PDT)
Date: Tue, 21 Mar 2017 15:25:04 -0700
In-Reply-To: <alpine.DEB.2.20.1703212319440.3776@nanos>
References: <20170321174711.29880-1-dsafonov@virtuozzo.com> <alpine.DEB.2.20.1703212319440.3776@nanos>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv3] x86/mm: set x32 syscall bit in SET_PERSONALITY()
From: hpa@zytor.com
Message-ID: <26CDE83A-CDBE-4F23-91F6-05B07B461BDD@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Adam Borowski <kilobyte@angband.pl>, linux-mm@kvack.org, Andrei Vagin <avagin@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>

On March 21, 2017 3:21:13 PM PDT, Thomas Gleixner <tglx@linutronix=2Ede> wr=
ote:
>On Tue, 21 Mar 2017, Dmitry Safonov wrote:
>> v3:
>> - clear x32 syscall flag during x32 -> x86-64 exec() (thanks, HPA)=2E
>
>For correctness sake, this wants to be cleared in the IA32 path as
>well=2E It's not causing any harm, but =2E=2E=2E=2E
>
>I'll amend the patch=2E
>
>Thanks,
>
>	tglx

Since the i386 syscall namespace is totally separate (and different), shou=
ld we simply change the system call number to the appropriate sys_execve nu=
mber?
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
