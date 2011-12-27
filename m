Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4A9066B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 17:54:20 -0500 (EST)
Received: by ggni2 with SMTP id i2so10375833ggn.14
        for <linux-mm@kvack.org>; Tue, 27 Dec 2011 14:54:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF8A59C.9050601@parallels.com>
References: <4EF78B6A.8020904@parallels.com> <4EF78B99.1020109@parallels.com>
 <CAHGf_=r5mmUJUaQLKgrY1rf9Qx0gO0hEJaHFehm5Zz7ZKMYUkQ@mail.gmail.com>
 <4EF89BCB.8070306@parallels.com> <CAHGf_=rJhpQyhWiVk_BALM7SG=rgbVLscLMqdmmC4OLBR70mOA@mail.gmail.com>
 <4EF8A59C.9050601@parallels.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 27 Dec 2011 17:53:58 -0500
Message-ID: <CAHGf_=q3yH4RgjcTLXSxaOKU12DswnCNY9v_hWwX4h_N6WkmzA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mincore: Introduce the MINCORE_ANON bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

> The tmpfs contents itself is supposed to be preserved, it's not a problem. The problem I'm trying
> to solve here is which page from task mappings (i.e. vm_area_struct-s) to save and which not to.
>
> Do the proposed MINCORE_RESIDENT and MINCORE_ANON bits have problems with this from
> your POV?

No problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
