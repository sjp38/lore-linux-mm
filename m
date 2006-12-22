Received: by ug-out-1314.google.com with SMTP id s2so2712690uge
        for <linux-mm@kvack.org>; Fri, 22 Dec 2006 01:57:32 -0800 (PST)
Message-ID: <cda58cb80612220157q5433c346pccd06b8b7cbaadba@mail.gmail.com>
Date: Fri, 22 Dec 2006 10:57:31 +0100
From: "Franck Bui-Huu" <vagabon.xyz@gmail.com>
Subject: Re: [RFC 2.6.19 1/1] fbdev,mm: hecuba/E-Ink fbdev driver v2
In-Reply-To: <cda58cb80612200050h6def9866nf1798753da9d842d@mail.gmail.com>
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
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/20/06, Franck Bui-Huu <vagabon.xyz@gmail.com> wrote:

>     - when mmaping your frame buffer , be sure that the virtual
>       address returned by mmap() to the application shares the
>       same cache lines than the ones the kernel
>       is using.

Well thinking more about it, this wouldn't work for all cache types.
For example, if your cache is not a direct maped one, this workaround
won't work. So this is definitely not a portable solution.

-- 
               Franck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
