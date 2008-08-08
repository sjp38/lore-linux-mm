Received: by rv-out-0708.google.com with SMTP id f25so774948rvb.26
        for <linux-mm@kvack.org>; Fri, 08 Aug 2008 01:23:45 -0700 (PDT)
Message-ID: <38b2ab8a0808080123t5083dc17qa250bd02c753f80d@mail.gmail.com>
Date: Fri, 8 Aug 2008 10:23:45 +0200
From: "Francis Moreau" <francis.moro@gmail.com>
Subject: Re: question about do_anonymous_page()
In-Reply-To: <38b2ab8a0808080101v795327f0n9da5adb33a3c1a9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <38b2ab8a0808080101v795327f0n9da5adb33a3c1a9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ resending with linux-mm address fixed, sorry ]

On Fri, Aug 8, 2008 at 10:01 AM, Francis Moreau <francis.moro@gmail.com> wrote:
> Hello,
>
> I'm wondering why do_anonymous_page() calls lru_cache_add_active(page)
> where page does not belong to the page cache ?
>
> Is it simply because lru_add_active() doesn't exist ?
>
> Thanks
> --
> Francis
>



-- 
Francis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
