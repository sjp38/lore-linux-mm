Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 48D3D6B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 08:16:24 -0500 (EST)
Received: by obbta7 with SMTP id ta7so4047046obb.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 05:16:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1312839019-17987-1-git-send-email-malchev@google.com>
References: <1312839019-17987-1-git-send-email-malchev@google.com>
Date: Mon, 23 Jan 2012 15:16:23 +0200
Message-ID: <CAOJsxLGFRLb=-sKfSuzxJ=MHtJ=x9mmCEqgY3B4UdFqppfz-sg@mail.gmail.com>
Subject: Re: [PATCH 1/2] slub: extend slub_debug to handle multiple slabs
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Iliyan Malchev <malchev@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Iliyan,

On Tue, Aug 9, 2011 at 12:30 AM, Iliyan Malchev <malchev@google.com> wrote:
> Extend the slub_debug syntax to "slub_debug=3D<flags>[,<slub>]*", where <=
slub>
> may contain an asterisk at the end. =A0For example, the following would p=
oison
> all kmalloc slabs:
>
> =A0 =A0 =A0 =A0slub_debug=3DP,kmalloc*
>
> and the following would apply the default flags to all kmalloc and all bl=
ock IO
> slabs:
>
> =A0 =A0 =A0 =A0slub_debug=3D,bio*,kmalloc*
>
> Signed-off-by: Iliyan Malchev <malchev@google.com>

Ping? I didn't see followup patches that addressed Christoph's review
comments. I think the feature makes sense so it'd be good to have it
in mainline.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
