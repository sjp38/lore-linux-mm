Received: by an-out-0708.google.com with SMTP id b38so340809ana
        for <linux-mm@kvack.org>; Sat, 16 Dec 2006 20:25:05 -0800 (PST)
Message-ID: <45a44e480612162025n5d7c77bdkc825e94f1fb37904@mail.gmail.com>
Date: Sat, 16 Dec 2006 23:25:04 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [RFC 2.6.19 1/1] fbdev,mm: hecuba/E-Ink fbdev driver v2
In-Reply-To: <cda58cb80612130038x6b81a00dv813d10726d495eda@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200612111046.kBBAkV8Y029087@localhost.localdomain>
	 <457D895D.4010500@innova-card.com>
	 <45a44e480612111554j1450f35ub4d9932e5cd32d4@mail.gmail.com>
	 <cda58cb80612130038x6b81a00dv813d10726d495eda@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Franck Bui-Huu <vagabon.xyz@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/13/06, Franck Bui-Huu <vagabon.xyz@gmail.com> wrote:
> On 12/12/06, Jaya Kumar <jayakumar.lkml@gmail.com> wrote:
> > I think that PTEs set up by vmalloc are marked cacheable and via the
> > above nopage end up as cacheable. I'm not doing DMA. So the accesses
> > are through the cache so I don't think cache aliasing is an issue for
> > this case. Please let me know if I misunderstood.
> >
>
> This issue is not related to DMA: there are 2 different virtual
> addresses that can map the same physical address. If these 2 virtual
> addresses use 2 different data cache entries then you have a cache
> aliasing issue. In your case the 2 different virtual addresses are (1)

Ok. I now see what you mean. In typical cases, only one path is used
to write. Meaning an app will decide to use the mmap path or the slow
write path and the kernel only ever reads from its pte entry (unless
fbcon is used which is not suited for this type of display). But you
are right that it is possible for a situation to arise where one app
does mmap and another is doing write. My hope is that something takes
care of flushing the data cache for me in this case. Do you recommend
I add something to force that? I'm worried about having an fbdev
driver that is too involved with mm.

Thanks,
jayakumar


> the one got by the kernel (returned by vmalloc) (2) the one got by the
> application (returned by mmap).
>
> Hope that helps.
> --
>                Franck
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
