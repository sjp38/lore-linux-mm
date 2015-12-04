Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 04DCE6B0254
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:45:10 -0500 (EST)
Received: by pfnn128 with SMTP id n128so17623791pfn.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:45:09 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ks7si15629044pab.109.2015.12.03.17.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 17:45:09 -0800 (PST)
Received: by pacwq6 with SMTP id wq6so955905pac.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:45:09 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH v2] clear file privilege bits when mmap writing
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151203000342.GA30015@www.outflux.net>
Date: Thu, 3 Dec 2015 17:45:06 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <B4520E53-6DD9-44D7-A064-9F405FBAA793@gmail.com>
References: <20151203000342.GA30015@www.outflux.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Willy Tarreau <w@1wt.eu>, "Eric W. Biederman" <ebiederm@xmission.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Dec 2, 2015, at 16:03, Kees Cook <keescook@chromium.org> wrote:
>=20
> Normally, when a user can modify a file that has setuid or setgid =
bits,
> those bits are cleared when they are not the file owner or a member
> of the group. This is enforced when using write and truncate but not
> when writing to a shared mmap on the file. This could allow the file
> writer to gain privileges by changing a binary without losing the
> setuid/setgid/caps bits.
>=20
> Changing the bits requires holding inode->i_mutex, so it cannot be =
done
> during the page fault (due to mmap_sem being held during the fault).
> Instead, clear the bits if PROT_WRITE is being used at mmap time.
>=20
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Cc: stable@vger.kernel.org
> =E2=80=94

is this means mprotect() sys call also need add this check?
mprotect() can change to PROT_WRITE, then it can write to a=20
read only map again , also a secure hole here .

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
