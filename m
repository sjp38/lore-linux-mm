Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD1216B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 12:26:20 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o16so8001939pgv.3
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:26:20 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k127si6518255pgc.352.2018.01.18.09.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 09:26:19 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [mm 4.15-rc8] Random oopses under memory pressure.
Date: Thu, 18 Jan 2018 17:26:15 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F7B3446FC@ORSMSX110.amr.corp.intel.com>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
In-Reply-To: <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "vbabka@suse.cz" <vbabka@suse.cz>, "mhocko@kernel.org" <mhocko@kernel.org>, "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>, "hughd@google.com" <hughd@google.com>, "oleg@redhat.com" <oleg@redhat.com>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

> Both are real page. But why do you expect pages to be 64-byte alinged?
> Both are aligned to 64-bit as they suppose to be IIUC.

On a 64-bit kernel sizeof struct page =3D=3D 64 (after much work by people =
to
trim out excess stuff).  So I thought we made sure to align the base addres=
s
of blocks of "struct page" so that every one neatly fits into one cache lin=
e.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
