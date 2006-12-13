Received: by ug-out-1314.google.com with SMTP id s2so94598uge
        for <linux-mm@kvack.org>; Wed, 13 Dec 2006 00:38:26 -0800 (PST)
Message-ID: <cda58cb80612130038x6b81a00dv813d10726d495eda@mail.gmail.com>
Date: Wed, 13 Dec 2006 09:38:26 +0100
From: "Franck Bui-Huu" <vagabon.xyz@gmail.com>
Subject: Re: [RFC 2.6.19 1/1] fbdev,mm: hecuba/E-Ink fbdev driver v2
In-Reply-To: <45a44e480612111554j1450f35ub4d9932e5cd32d4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200612111046.kBBAkV8Y029087@localhost.localdomain>
	 <457D895D.4010500@innova-card.com>
	 <45a44e480612111554j1450f35ub4d9932e5cd32d4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/12/06, Jaya Kumar <jayakumar.lkml@gmail.com> wrote:
> I think that PTEs set up by vmalloc are marked cacheable and via the
> above nopage end up as cacheable. I'm not doing DMA. So the accesses
> are through the cache so I don't think cache aliasing is an issue for
> this case. Please let me know if I misunderstood.
>

This issue is not related to DMA: there are 2 different virtual
addresses that can map the same physical address. If these 2 virtual
addresses use 2 different data cache entries then you have a cache
aliasing issue. In your case the 2 different virtual addresses are (1)
the one got by the kernel (returned by vmalloc) (2) the one got by the
application (returned by mmap).

Hope that helps.
-- 
               Franck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
