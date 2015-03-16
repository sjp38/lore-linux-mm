Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0D72D6B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:26:28 -0400 (EDT)
Received: by qcto4 with SMTP id o4so55257752qct.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 13:26:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 84si10922931qhx.130.2015.03.16.13.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 13:26:27 -0700 (PDT)
Date: Mon, 16 Mar 2015 20:44:46 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: install_special_mapping && vm_pgoff (Was: vvar, gup &&
	coredump)
Message-ID: <20150316194446.GA21791@redhat.com>
References: <20150305154827.GA9441@host1.jankratochvil.net> <87zj7r5fpz.fsf@redhat.com> <20150305205744.GA13165@host1.jankratochvil.net> <20150311200052.GA22654@redhat.com> <20150312143438.GA4338@redhat.com> <CALCETrW5rmAHutzm_OwK2LTd_J0XByV3pvWGyW=AmC=v7rLfhQ@mail.gmail.com> <20150312165423.GA10073@redhat.com> <20150312174653.GA13086@redhat.com> <20150316190154.GA18472@redhat.com> <CALCETrU9pLE2x3+vei1xw6B8uu4B33DOEzP03ue9DeS8sJhYUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrU9pLE2x3+vei1xw6B8uu4B33DOEzP03ue9DeS8sJhYUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kratochvil <jan.kratochvil@redhat.com>, Sergio Durigan Junior <sergiodj@redhat.com>, GDB Patches <gdb-patches@sourceware.org>, Pedro Alves <palves@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/16, Andy Lutomirski wrote:
>
> Ick, you're probably right.  For what it's worth, the vdso *seems* to
> be okay (on 64-bit only, and only if you don't poke at it too hard) if
> you mremap it in one piece.  CRIU does that.

I need to run away till tomorrow, but looking at this code even if "one piece"
case doesn't look right if it was cow'ed. I'll verify tomorrow.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
