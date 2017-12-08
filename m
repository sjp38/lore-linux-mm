Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5DBB6B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 15:13:34 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id z85so6210475vkd.22
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 12:13:34 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v27sor3206135uae.75.2017.12.08.12.13.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 12:13:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171208083315.GR20234@dhcp22.suse.cz>
References: <20171129144219.22867-1-mhocko@kernel.org> <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au> <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org> <87bmjbks4c.fsf@concordia.ellerman.id.au>
 <CAGXu5jLWRQn6EaXEEvdvXr+4gbiJawwp1EaLMfYisHVfMiqgSA@mail.gmail.com>
 <20171207195727.GA26792@bombadil.infradead.org> <20171208083315.GR20234@dhcp22.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 8 Dec 2017 12:13:31 -0800
Message-ID: <CAGXu5j+VupGmKEEHx-uNXw27Xvndu=0ObsBqMwQiaYPyMGD+vw@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Michael Ellerman <mpe@ellerman.id.au>, Cyril Hrubis <chrubis@suse.cz>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Pavel Machek <pavel@ucw.cz>

On Fri, Dec 8, 2017 at 12:33 AM, Michal Hocko <mhocko@kernel.org> wrote:
> OK, this doesn't seem to lead to anywhere. The more this is discussed
> the more names we are getting. So you know what? I will resubmit and
> keep my original name. If somebody really hates it then feel free to
> nack the patch and push alternative and gain concensus on it.
>
> I will keep MAP_FIXED_SAFE because it is an alternative to MAP_FIXED so
> having that in the name is _useful_ for everybody familiar with
> MAP_FIXED already. And _SAFE suffix tells that the operation doesn't
> cause any silent memory corruptions or other unexpected side effects.

Looks like consensus is MAP_FIXED_NOREPLACE.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
