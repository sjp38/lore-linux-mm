Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0B8E96B0047
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 04:30:36 -0500 (EST)
Received: by fk-out-0910.google.com with SMTP id z22so555579fkz.6
        for <linux-mm@kvack.org>; Fri, 13 Feb 2009 01:30:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <84144f020902130122y471dd92em4a72de43a0cfc681@mail.gmail.com>
References: <1234461073-23281-1-git-send-email-peppe.cavallaro@st.com>
	 <20090212185640.GA6111@linux-sh.org> <499544AD.3030804@st.com>
	 <84144f020902130122y471dd92em4a72de43a0cfc681@mail.gmail.com>
Date: Fri, 13 Feb 2009 11:30:34 +0200
Message-ID: <84144f020902130130k7d66bd0i7637ec0589d3bee1@mail.gmail.com>
Subject: Re: [PATCH] slab: fix slab flags for archs use alignment larger
	64-bit
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Cc: Paul Mundt <lethal@linux-sh.org>, linux-kernel@vger.kernel.org, linux-sh@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 13, 2009 at 11:22 AM, Pekka Enberg <penberg@cs.helsinki.fi> wro=
te:
> That sounds unfortunate. Can you post
>
> =A0cat /proc/meminfo | grep Slab
>
> results on sh without and with your patch? Bumping the limit up to
> ARCH_KMALLOC_MINALIGN does make sense but we'd need to know what kind
> of problems it might cause.

You probably want to fix up the issues Paul raised, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
