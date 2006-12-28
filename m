Received: by an-out-0708.google.com with SMTP id b38so1097768ana
        for <linux-mm@kvack.org>; Wed, 27 Dec 2006 19:53:13 -0800 (PST)
Message-ID: <45a44e480612271953we6fe8adg118560161579b7f9@mail.gmail.com>
Date: Thu, 28 Dec 2006 04:53:13 +0100
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [RFC 2.6.19 1/1] fbdev,mm: hecuba/E-Ink fbdev driver v2
In-Reply-To: <cda58cb80612220157q5433c346pccd06b8b7cbaadba@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200612111046.kBBAkV8Y029087@localhost.localdomain>
	 <457D895D.4010500@innova-card.com>
	 <45a44e480612111554j1450f35ub4d9932e5cd32d4@mail.gmail.com>
	 <cda58cb80612130038x6b81a00dv813d10726d495eda@mail.gmail.com>
	 <45a44e480612162025n5d7c77bdkc825e94f1fb37904@mail.gmail.com>
	 <cda58cb80612200050h6def9866nf1798753da9d842d@mail.gmail.com>
	 <cda58cb80612220157q5433c346pccd06b8b7cbaadba@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Franck Bui-Huu <vagabon.xyz@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/22/06, Franck Bui-Huu <vagabon.xyz@gmail.com> wrote:
>
> Well thinking more about it, this wouldn't work for all cache types.
> For example, if your cache is not a direct maped one, this workaround
> won't work. So this is definitely not a portable solution.
>

>From asking peterz on #mm, I think page_mkclean will do the right
thing and call something like flush_cache_page. I think that resolves
the issue which I think you identified where the end symptom on archs
with virtually tagged caches could be a line of pixels written by
userspace through one PTE remain in-cache and therefore "undisplayed"
when the kernel reads through another PTE that may fall on a different
cacheline.

Thanks,
jayakumar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
