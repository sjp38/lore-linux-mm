Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id F31146B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 20:54:57 -0400 (EDT)
Received: by dadq36 with SMTP id q36so958248dad.8
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 17:54:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHnt0GWABX8qOVTinmSETUHxq1Y3NhqPOKxnUgcDtyf8wjtg_g@mail.gmail.com>
References: <CAHnt0GXW-pyOUuBLB1n6qBP4WNGpET9er_HbJ29s5j5DE1xAdA@mail.gmail.com>
	<20120425222819.GF8989@google.com>
	<CAHnt0GWABX8qOVTinmSETUHxq1Y3NhqPOKxnUgcDtyf8wjtg_g@mail.gmail.com>
Date: Wed, 25 Apr 2012 17:54:57 -0700
Message-ID: <CAE9FiQUyF+yw4vNL1YziGtm9wXgGSy55nesB+BxM-gG8Zu=YtQ@mail.gmail.com>
Subject: Re: [BUG]memblock: fix overflow of array index
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Teoh <htmldeveloper@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org

On Wed, Apr 25, 2012 at 5:50 PM, Peter Teoh <htmldeveloper@gmail.com> wrote=
:
> Thanks for the reply. =A0 Just an educational question: =A0is it possible
> to set one-byte per memblock? =A0 =A0And what is the minimum memblock
> size?

yes. 1 byte.

>
> Even if 2G memblock is a huge number, it still seemed like a bug to me
> that there is no check on the maximum number (which is 2G) of this
> variable (assuming signed int). =A0 Software can always purposely push
> that number up and the system can panic?

before slab is ready? how?

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
